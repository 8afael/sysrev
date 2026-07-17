from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, Assignment, Review, ProjectUser
from app.models.enums import ProjectRole
from app.schemas.review_schema import AssignmentCreate, AssignmentOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/projects/{project_id}/assignments", tags=["assignments"])


@router.post("", response_model=AssignmentOut, status_code=201)
async def create_assignment(
    project_id: str,
    payload: AssignmentCreate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """Manual assignment (MVP). The `method` field already accepts 'ai' in the schema so
    compatibility isn't broken when the AI layer is implemented — for now, any value other
    than manual/random/rule is handled normally without real AI logic."""
    # validate that the reviewer belongs to the project
    result = await db.execute(
        select(ProjectUser).where(
            ProjectUser.project_id == project_id,
            ProjectUser.user_id == payload.reviewer_id,
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="User is not a member of this project")

    # Assignment doesn't store project_id directly (the link comes via document_id -> Document.project_id)
    assignment = Assignment(**payload.model_dump(), assigned_by=user.id)
    db.add(assignment)
    await db.flush()

    # automatically create the empty associated review record
    review = Review(assignment_id=assignment.id)
    db.add(review)

    await log_audit(
        db, user.id, "create", "assignment", assignment.id,
        data_after=payload.model_dump(mode="json"),
    )
    await db.commit()
    await db.refresh(assignment)
    return assignment


@router.get("", response_model=List[AssignmentOut])
async def list_project_assignments(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Admin/Arbiter see all; Reviewer only sees their own."""
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(status_code=403, detail="No access to this project")

    stmt = select(Assignment).join(
        Assignment.document
    ).where(Assignment.document.has(project_id=project_id))

    if role == ProjectRole.reviewer:
        stmt = stmt.where(Assignment.reviewer_id == user.id)

    result = await db.execute(stmt.order_by(Assignment.created_at.desc()))
    return result.scalars().all()


@router.get("/mine", response_model=List[AssignmentOut])
async def my_assignments(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Shortcut for the reviewer's dashboard: only their tasks in this project."""
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(status_code=403, detail="No access to this project")

    result = await db.execute(
        select(Assignment)
        .join(Assignment.document)
        .where(Assignment.document.has(project_id=project_id), Assignment.reviewer_id == user.id)
        .order_by(Assignment.created_at.desc())
    )
    return result.scalars().all()