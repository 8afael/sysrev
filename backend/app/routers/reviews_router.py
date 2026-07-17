from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.models import User, Assignment, Review, Conflict
from app.models.enums import AssignmentStatus, ConflictStatus
from app.schemas.review_schema import ReviewUpdate, ReviewOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/assignments/{assignment_id}/review", tags=["reviews"])


async def _get_user_assignment(assignment_id: str, user: User, db: AsyncSession) -> Assignment:
    result = await db.execute(select(Assignment).where(Assignment.id == assignment_id))
    assignment = result.scalar_one_or_none()
    if not assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")
    if assignment.reviewer_id != user.id:
        raise HTTPException(status_code=403, detail="This assignment does not belong to you")
    return assignment


@router.get("", response_model=ReviewOut)
async def get_review(
    assignment_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    assignment = await _get_user_assignment(assignment_id, user, db)
    result = await db.execute(select(Review).where(Review.assignment_id == assignment.id))
    review = result.scalar_one_or_none()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    return review


@router.put("", response_model=ReviewOut)
async def save_review(
    assignment_id: str,
    payload: ReviewUpdate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Autosave: can be called multiple times with finished=False.
    When finished=True, the assignment changes status and the system checks
    if there is already another review for the same document to detect conflicts."""
    assignment = await _get_user_assignment(assignment_id, user, db)

    result = await db.execute(select(Review).where(Review.assignment_id == assignment.id))
    review = result.scalar_one_or_none()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")

    review.json_responses = payload.json_responses
    review.decision = payload.decision
    review.exclusion_reason = payload.exclusion_reason
    review.confidence = payload.confidence
    review.finished = payload.finished

    assignment.status = (
        AssignmentStatus.completed if payload.finished else AssignmentStatus.ongoing
    )

    if payload.finished:
        await _check_conflict(db, assignment, review, user.id)

    await log_audit(
        db, 
        user.id, 
        "save_review", 
        "review", 
        review.id,
        data_after={"finished": payload.finished, "decision": str(payload.decision)}
    )
    await db.commit()
    await db.refresh(review)
    return review


async def _check_conflict(db: AsyncSession, assignment: Assignment, current_review: Review, user_id: str):
    """Compares with other finished reviews of the same document. If the decisions
    diverge, it opens a Conflict record for the arbiter to resolve."""
    result = await db.execute(
        select(Assignment).where(
            Assignment.document_id == assignment.document_id,
            Assignment.id != assignment.id,
        )
    )
    other_assignments = result.scalars().all()

    for other in other_assignments:
        result_rev = await db.execute(select(Review).where(Review.assignment_id == other.id))
        other_review = result_rev.scalar_one_or_none()
        if other_review and other_review.finished and other_review.decision != current_review.decision:
            existing_conflict = await db.execute(
                select(Conflict).where(
                    Conflict.document_id == assignment.document_id,
                    Conflict.status != ConflictStatus.resolved,
                )
            )
            if existing_conflict.scalar_one_or_none():
                continue  # there is already an open conflict for this document

            conflict = Conflict(
                document_id=assignment.document_id,
                review1_id=other_review.id,
                review2_id=current_review.id,
                status=ConflictStatus.open,
            )
            db.add(conflict)
            await log_audit(
                db, 
                user_id, 
                "open_conflict", 
                "conflict", 
                None,
                data_after={"document_id": assignment.document_id}
            )