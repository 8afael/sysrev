from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, Document
from app.models.enums import ProjectRole
from app.schemas.review_schema import DocumentCreate, DocumentOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/projects/{project_id}/documents", tags=["documents"])

@router.post("", response_model=DocumentOut, status_code=201)
async def register_document(
    project_id: str,
    payload: DocumentCreate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """MVP: only admin registers documents (direct upload or external reference).
    Copyright rule: if `file_url` is not provided, the document remains only with
    `external_reference`, without redistributing protected text."""
    doc = Document(project_id=project_id, **payload.model_dump())
    db.add(doc)
    await log_audit(db, user.id, "create", "document", None, data_after={"title": payload.title})
    await db.commit()
    await db.refresh(doc)
    return doc

@router.get("", response_model=List[DocumentOut])
async def list_documents(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(status_code=403, detail="No access to this project")

    result = await db.execute(
        select(Document).where(Document.project_id == project_id).order_by(Document.created_at.desc())
    )
    return result.scalars().all()

@router.delete("/{document_id}", status_code=204)
async def delete_document(
    project_id: str,
    document_id: str,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Document).where(Document.id == document_id))
    doc = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    await log_audit(db, user.id, "delete", "document", document_id)
    await db.delete(doc)
    await db.commit()