from datetime import datetime
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, Conflict, Document
from app.models.enums import ProjectRole, ConflictStatus
from app.schemas.review_schema import ConflictResolve, ConflictOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/projects/{project_id}/conflicts", tags=["conflicts"])

@router.get("", response_model=List[ConflictOut])
async def list_conflicts(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Admin sees all; Arbiter sees the ones they need to resolve; Reviewer has no access."""
    role = await get_role_in_project(project_id, user, db)
    if role not in (ProjectRole.admin, ProjectRole.arbiter):
        raise HTTPException(status_code=403, detail="Only admins or arbiters can view conflicts")

    result = await db.execute(
        select(Conflict).join(Document).where(Document.project_id == project_id)
        .order_by(Conflict.created_at.desc())
    )
    return result.scalars().all()

@router.put("/{conflict_id}/resolve", response_model=ConflictOut)
async def resolve_conflict(
    project_id: str,
    conflict_id: str,
    payload: ConflictResolve,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin, ProjectRole.arbiter)),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Conflict).where(Conflict.id == conflict_id))
    conflict = result.scalar_one_or_none()
    if not conflict:
        raise HTTPException(status_code=404, detail="Conflict not found")

    conflict.status = ConflictStatus.resolved
    conflict.final_decision = payload.final_decision
    conflict.arbiter_justification = payload.arbiter_justification
    conflict.arbiter_id = user.id
    conflict.resolved_at = datetime.utcnow()

    await log_audit(
        db, 
        user.id, 
        "resolve_conflict", 
        "conflict", 
        conflict_id,
        data_after={"final_decision": payload.final_decision.value}
    )
    await db.commit()
    await db.refresh(conflict)
    return conflict