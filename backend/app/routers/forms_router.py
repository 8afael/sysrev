from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, FormSchema, FormResponse, Assignment
from app.models.enums import ProjectRole
from app.schemas.review_schema import FormSchemaCreate, FormSchemaOut  # Lembre-se de atualizar esses Pydantic schemas se necessário
from app.services.audit_service import log_audit

router = APIRouter(tags=["forms"])


# =====================================================================
# 1. SALVAR / ATUALIZAR SCHEMA DO FORMULÁRIO (Apenas Admins do Projeto)
# =====================================================================
@router.post("/projects/{project_id}/forms", response_model=FormSchemaOut, status_code=status.HTTP_201_CREATED)
async def create_or_update_form(
    project_id: str,
    payload: FormSchemaCreate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """Cria ou atualiza o esquema do formulário associado ao projeto."""
    
    # Busca se já existe um formulário registrado para o projeto
    result = await db.execute(
        select(FormSchema).where(FormSchema.project_id == project_id)
    )
    form = result.scalars().first()

    action = "update" if form else "create"

    if not form:
        form = FormSchema(project_id=project_id)
        db.add(form)

    # Atualiza as propriedades conforme a model
    form.title = payload.title
    form.description = payload.description
    form.structure = payload.structure  # Dict contendo seções, perguntas e validações

    await log_audit(
        db, 
        user.id, 
        f"{action}_form_schema", 
        "form_schema", 
        project_id,
        data_after={"title": payload.title, "project_id": project_id}
    )

    await db.commit()
    await db.refresh(form)
    return form


# =====================================================================
# 2. BUSCAR SCHEMA DO FORMULÁRIO DO PROJETO
# =====================================================================
@router.get("/projects/{project_id}/forms", response_model=Optional[FormSchemaOut])
async def get_project_form(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retorna o esquema do formulário configurado para o projeto."""
    
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="No access to this project"
        )

    stmt = select(FormSchema).where(FormSchema.project_id == project_id)
    result = await db.execute(stmt)
    form = result.scalars().first()

    if not form:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Form schema not found for this project"
        )

    return form


# =====================================================================
# 3. SUBMETER RESPOSTA DO FORMULÁRIO (Revisores)
# =====================================================================
# Schema Pydantic local/auxiliar para recebimento das respostas
class FormResponseCreate(BaseModel):
    assignment_id: Optional[str] = None
    answers: dict = Field(default_factory=dict)

@router.post("/forms/{form_id}/responses", status_code=status.HTTP_201_CREATED)
async def submit_form_response(
    form_id: str,
    payload: FormResponseCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Envia uma resposta preenchida para o formulário."""
    
    # Valida se o formulário existe
    form_stmt = select(FormSchema).where(FormSchema.id == form_id)
    form_res = await db.execute(form_stmt)
    form = form_res.scalars().first()

    if not form:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail="Form schema not found"
        )

    # Cria a resposta
    response = FormResponse(
        form_schema_id=form_id,
        assignment_id=payload.assignment_id,
        reviewer_id=user.id,
        answers=payload.answers
    )
    db.add(response)

    await log_audit(
        db, 
        user.id, 
        "submit_form_response", 
        "form_response", 
        form.project_id,
        data_after={"form_schema_id": form_id, "assignment_id": payload.assignment_id}
    )

    await db.commit()
    await db.refresh(response)

    return {
        "message": "Response submitted successfully", 
        "id": response.id,
        "submitted_at": response.submitted_at
    }
