from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, FormSchema
from app.models.enums import ProjectRole
from app.schemas.review_schema import FormSchemaCreate, FormSchemaOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/projects/{project_id}/forms", tags=["forms"])


@router.post("", response_model=FormSchemaOut, status_code=201)
async def create_or_version_form(
    project_id: str,
    payload: FormSchemaCreate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """Creates a new form. If an active one with the same name/group/protocol already exists,
    deactivates the previous one and creates a new version — never overwrites (important so
    we don't invalidate evaluations already answered with the old schema)."""
    result = await db.execute(
        select(FormSchema).where(
            FormSchema.project_id == project_id,
            FormSchema.protocol == payload.protocol,
            FormSchema.group == payload.group,
            FormSchema.name == payload.name,
            FormSchema.is_active == True,  # noqa: E712
        )
    )
    previous = result.scalar_one_or_none()
    new_version = 1
    if previous:
        previous.is_active = False
        new_version = previous.version + 1

    new_form = FormSchema(
        project_id=project_id,
        protocol=payload.protocol,
        group=payload.group,
        name=payload.name,
        json_fields=payload.json_fields,
        version=new_version,
        created_by=user.id,
    )
    db.add(new_form)
    await log_audit(
        db, 
        user.id, 
        "create_version", 
        "form_schema", 
        project_id,
        data_after={"name": payload.name, "version": new_version}
    )
    await db.commit()
    await db.refresh(new_form)
    return new_form


@router.get("", response_model=List[FormSchemaOut])
async def list_forms(
    project_id: str,
    only_active: bool = True,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(status_code=403, detail="No access to this project")

    stmt = select(FormSchema).where(FormSchema.project_id == project_id)
    if only_active:
        stmt = stmt.where(FormSchema.is_active == True)  # noqa: E712
    result = await db.execute(stmt.order_by(FormSchema.created_at.desc()))
    return result.scalars().all()