from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import Document, User, Assignment, Review, ProjectUser
from app.models.enums import AssignmentRole, ProjectRole
from app.schemas.review_schema import AssignmentCreate, AssignmentOut
from app.services.audit_service import log_audit
from app.schemas.assignment_schema import AssignmentBulkUpdateIn, AssignmentBulkUpdateOut

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
    
    data = payload.model_dump()
    data["role"] = AssignmentRole.reviewer1

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

    stmt = (
    select(Assignment)
    .join(Assignment.document)
     .options(selectinload(Assignment.document)) 
    .where(Assignment.document.has(project_id=project_id))
    )

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

@router.put(
    "/bulk-update",
    response_model=AssignmentBulkUpdateOut,
    status_code=200,
)

@router.put(
    "/bulk-update",
    response_model=AssignmentBulkUpdateOut,
    status_code=200,
)
async def bulk_update_assignments(
    project_id: str,
    payload: AssignmentBulkUpdateIn,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    if not payload.documents:
        raise HTTPException(status_code=400, detail="No documents provided.")

    doc_ids = [d.document_id for d in payload.documents]

    # 1) Validate documents belong to this project
    result = await db.execute(
        select(Document.id).where(
            Document.id.in_([str(d) for d in doc_ids]),
            Document.project_id == project_id,
        )
    )
    valid_doc_ids = {str(row[0]) for row in result.all()}
    invalid = [str(d) for d in doc_ids if str(d) not in valid_doc_ids]
    if invalid:
        raise HTTPException(
            status_code=400,
            detail=f"Documents not found in this project: {', '.join(invalid)}",
        )

    # 2) Validate every user is a member of the project (single query)
    all_user_ids = {
        member.user_id for d in payload.documents for member in d.assigned_members  # 👈
    }
    if all_user_ids:
        result = await db.execute(
            select(ProjectUser.user_id).where(
                ProjectUser.project_id == project_id,
                ProjectUser.user_id.in_([str(u) for u in all_user_ids]),
            )
        )
        member_ids = {str(row[0]) for row in result.all()}
        not_members = [str(u) for u in all_user_ids if str(u) not in member_ids]
        if not_members:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Some users are not members of this project: "
                    f"{', '.join(not_members)}"
                ),
            )

    deleted_count = 0
    created_count = 0

    for doc in payload.documents:
        old_result = await db.execute(
            select(Assignment.id).where(Assignment.document_id == doc.document_id)
        )
        old_ids = [row[0] for row in old_result.all()]

        if old_ids:
            await db.execute(delete(Review).where(Review.assignment_id.in_(old_ids)))
            await db.execute(delete(Assignment).where(Assignment.id.in_(old_ids)))
            deleted_count += len(old_ids)

        # 👇 agora usa o papel escolhido pelo admin, em vez de fixar reviewer1
        for member in doc.assigned_members:
            assignment = Assignment(
                document_id=doc.document_id,
                reviewer_id=member.user_id,
                role=member.role,
                method="manual",
                assigned_by=user.id,
            )
            db.add(assignment)
            await db.flush()

            review = Review(assignment_id=assignment.id)
            db.add(review)

            created_count += 1

    await log_audit(
        db,
        user.id,
        "bulk_update",
        "assignment",
        project_id,
        data_after={
            "documents": [
                {
                    "document_id": str(d.document_id),
                    "assigned_members": [
                        {"user_id": str(m.user_id), "role": m.role.value}
                        for m in d.assigned_members
                    ],
                }
                for d in payload.documents
            ],
            "created": created_count,
            "deleted": deleted_count,
        },
    )

    await db.commit()

    return AssignmentBulkUpdateOut(
        updated_documents=len(payload.documents),
        created_assignments=created_count,
        deleted_assignments=deleted_count,
    )