from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.models import (
    User, Project, ProjectUser, Document, Conflict,
)
from app.models.enums import (
    ProjectRole, ProjectStatus, ConflictStatus, DocumentPhase,
)

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/admin")
async def dashboard_admin(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Metrics of the projects managed by the ADMIN user
    (role = admin in ProjectUser).
    """
    # IDs of the projects that this user manages
    result = await db.execute(
        select(Project.id)
        .join(ProjectUser, ProjectUser.project_id == Project.id)
        .where(
            and_(
                ProjectUser.user_id == user.id,
                ProjectUser.role == ProjectRole.admin,
            )
        )
    )
    project_ids = [row[0] for row in result.all()]

    if not project_ids:
        return {
            "total_projects": 0,
            "ongoing_projects": 0,
            "total_documents": 0,
            "documents_by_phase": {},
            "open_conflicts": 0,
        }

    # total projects
    total_projects = len(project_ids)

    # ongoing projects
    r = await db.execute(
        select(func.count(Project.id)).where(
            and_(
                Project.id.in_(project_ids),
                Project.status == ProjectStatus.in_progress,
            )
        )
    )
    ongoing_projects = r.scalar_one() or 0

    # total documents
    r = await db.execute(
        select(func.count(Document.id)).where(Document.project_id.in_(project_ids))
    )
    total_documents = r.scalar_one() or 0

    # documents by phase
    r = await db.execute(
        select(Document.phase, func.count(Document.id))
        .where(Document.project_id.in_(project_ids))
        .group_by(Document.phase)
    )
    documents_by_phase = {}
    for phase, qty in r.all():
        key = phase.value if hasattr(phase, "value") else str(phase)
        documents_by_phase[key] = qty

    # open conflicts
    r = await db.execute(
        select(func.count(Conflict.id))
        .join(Document, Document.id == Conflict.document_id)
        .where(
            and_(
                Document.project_id.in_(project_ids),
                Conflict.status == ConflictStatus.open,
            )
        )
    )
    open_conflicts = r.scalar_one() or 0

    return {
        "total_projects": total_projects,
        "ongoing_projects": ongoing_projects,
        "total_documents": total_documents,
        "documents_by_phase": documents_by_phase,
        "open_conflicts": open_conflicts,
    }


@router.get("/reviewer")
async def dashboard_reviewer(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Metrics for the user while acting as reviewer/arbiter."""
    result = await db.execute(
        select(Project.id)
        .join(ProjectUser, ProjectUser.project_id == Project.id)
        .where(
            and_(
                ProjectUser.user_id == user.id,
                ProjectUser.role.in_([ProjectRole.reviewer, ProjectRole.arbiter]),
            )
        )
    )
    project_ids = [row[0] for row in result.all()]

    if not project_ids:
        return {
            "total_projects": 0,
            "documents_by_phase": {},
        }

    r = await db.execute(
        select(Document.phase, func.count(Document.id))
        .where(Document.project_id.in_(project_ids))
        .group_by(Document.phase)
    )
    documents_by_phase = {}
    for phase, qty in r.all():
        key = phase.value if hasattr(phase, "value") else str(phase)
        documents_by_phase[key] = qty

    return {
        "total_projects": len(project_ids),
        "documents_by_phase": documents_by_phase,
    }