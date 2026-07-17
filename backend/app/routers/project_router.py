from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, delete
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload, selectinload
from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, Project, ProjectUser, WorkGroup, Country, Language
from app.models.enums import ProjectRole
from app.schemas.project_schema import ProjectCreate, ProjectUpdate, ProjectOut, MemberAdd, MemberOut
from app.services.audit_service import log_audit

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("", response_model=ProjectOut, status_code=201)
async def create_project(
    payload: ProjectCreate,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    #project_data = payload.model_dump(exclude={"work_group_ids", "country_ids", "language_ids"})
    project_data = payload.model_dump(exclude={"work_group_ids", "country_ids", "language_ids", "members"})
    project = Project(**project_data, created_by=user.id)
    
    if payload.work_group_ids:
        groups_result = await db.execute(
            select(WorkGroup).where(WorkGroup.id.in_(payload.work_group_ids))
        )
        project.work_groups = list(groups_result.scalars().all())

    if payload.country_ids:
        countries_result = await db.execute(
            select(Country).where(Country.id.in_(payload.country_ids))
        )
        project.countries = list(countries_result.scalars().all())

    if payload.language_ids:
        languages_result = await db.execute(
            select(Language).where(Language.id.in_(payload.language_ids))
        )
        project.languages = list(languages_result.scalars().all())

    db.add(project)
    await db.flush()

    if payload.members:
        for member_input in payload.members:
            # Evita duplicar o criador se ele já veio na lista do frontend
            if str(member_input.user_id) == str(user.id):
                continue
                
            new_member = ProjectUser(
                project_id=project.id,
                user_id=str(member_input.user_id),
                role=member_input.role,
                accepted=True
            )
            db.add(new_member)

    member = ProjectUser(project_id=project.id, user_id=user.id, role=ProjectRole.admin)
    db.add(member)

    await log_audit(
        db, 
        user.id, 
        "create", 
        "project", 
        project.id, 
        data_after=payload.model_dump(mode="json")
    )
    await db.commit()
    
    result = await db.execute(
        select(Project)
        .options(
            selectinload(Project.work_groups).selectinload(WorkGroup.members),
            selectinload(Project.countries),
            selectinload(Project.languages),
            selectinload(Project.members).joinedload(ProjectUser.user)
        )
        .where(Project.id == project.id)
    )
    return result.scalar_one()

@router.get("", response_model=List[ProjectOut])
async def list_my_projects(
    role: Optional[ProjectRole] = None,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Base da Query carregando os relacionamentos necessários
    stmt = select(Project).options(
        selectinload(Project.work_groups).selectinload(WorkGroup.members),
        selectinload(Project.countries),
        selectinload(Project.languages),
        selectinload(Project.members).joinedload(ProjectUser.user)
    )

    # 🌟 Se NÃO for admin do sistema, filtra apenas os projetos onde ele está inserido
    is_system_admin = getattr(user, "is_admin", False)

    if not is_system_admin:
        # Usuário comum: só vê onde está associado
        stmt = stmt.join(ProjectUser, ProjectUser.project_id == Project.id).where(
            ProjectUser.user_id == user.id
        )
        if role is not None:
            stmt = stmt.where(ProjectUser.role == role)
    else:
        # Admin do Sistema: vê tudo
        stmt = stmt.order_by(Project.created_at.desc())
    
    if not is_system_admin:
        stmt = stmt.join(ProjectUser, ProjectUser.project_id == Project.id).where(
            ProjectUser.user_id == user.id
        )
        if role is not None:
            stmt = stmt.where(ProjectUser.role == role)
            
    else:
        # Se for admin, lista tudo por ordem de criação
        stmt = stmt.order_by(Project.created_at.desc())

    result = await db.execute(stmt)
    return result.scalars().all()

# @router.get("", response_model=List[ProjectOut])
# async def list_my_projects(
#     role: Optional[ProjectRole] = None,
#     user: User = Depends(get_current_user),
#     db: AsyncSession = Depends(get_db),
# ):
   
#     stmt = (
#         select(Project)
#         .options(
#             # 🌟 Atualizado aqui para puxar os membros do grupo de trabalho junto!
#             selectinload(Project.work_groups).selectinload(WorkGroup.members),
#             selectinload(Project.countries),
#             selectinload(Project.languages),
#             selectinload(Project.members).joinedload(ProjectUser.user)
#         )
#         .join(ProjectUser, ProjectUser.project_id == Project.id)
#         .where(ProjectUser.user_id == user.id)
#         .order_by(Project.created_at.desc())
#     )
#     if role is not None:
#         stmt = stmt.where(ProjectUser.role == role)

#     result = await db.execute(stmt)
#     return result.scalars().all()


@router.get("/{project_id}", response_model=ProjectOut)
async def get_project(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    is_system_admin = getattr(user, "is_admin", False)

    if not is_system_admin:
        role = await get_role_in_project(project_id, user, db)
        if role is None:
            raise HTTPException(status_code=403, detail="No access to this project")

    result = await db.execute(
        select(Project)
        .options(
            selectinload(Project.work_groups).selectinload(WorkGroup.members),
            selectinload(Project.countries),
            selectinload(Project.languages),
            selectinload(Project.members).joinedload(ProjectUser.user)
        )
        .where(Project.id == project_id)
    )
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project

@router.put("/{project_id}", response_model=ProjectOut)
async def update_project(
    project_id: UUID,
    payload: ProjectUpdate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    pid_str = str(project_id)
    result = await db.execute(
        select(Project)
        .options(
            selectinload(Project.work_groups).selectinload(WorkGroup.members),
            selectinload(Project.countries),
            selectinload(Project.languages)  
        )
        .where(Project.id == project_id)
    )
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    data_before = {"title": project.title, "status": project.status.value}

    exclude_fields = {"work_group_ids", "country_ids", "language_ids", "members"}
    update_data = payload.model_dump(exclude_unset=True, exclude=exclude_fields)

    for field, value in update_data.items():
        setattr(project, field, value)

    if payload.work_group_ids is not None:
        groups_result = await db.execute(
            select(WorkGroup).where(WorkGroup.id.in_(payload.work_group_ids))
        )
        project.work_groups = list(groups_result.scalars().all())

    if payload.country_ids is not None:
        countries_result = await db.execute(
            select(Country).where(Country.id.in_(payload.country_ids))
        )
        project.countries = list(countries_result.scalars().all())

    if payload.language_ids is not None:
        languages_result = await db.execute(
            select(Language).where(Language.id.in_(payload.language_ids))
        )
        project.languages = list(languages_result.scalars().all())

    if payload.members is not None:
        # Remove os membros antigos vinculados a esse projeto
        await db.execute(
            delete(ProjectUser).where(ProjectUser.project_id == pid_str)
        )
        # Salva a nova lista atualizada vinda do Front
        for member_input in payload.members:
            new_member = ProjectUser(
                project_id=pid_str,
                user_id=str(member_input.user_id),
                role=member_input.role,
                accepted=True
            )
            db.add(new_member)
            
        # Trava de segurança: Garante que o Admin que está salvando a alteração não se remova do projeto por engano
        admin_still_in = any(str(m.user_id) == str(user.id) for m in payload.members)
        if not admin_still_in:
            db.add(ProjectUser(project_id=pid_str, user_id=user.id, role=ProjectRole.admin))

    await log_audit(
        db, 
        user.id, 
        "update", 
        "project", 
        project_id, 
        data_before=data_before
    )
    await db.commit()

    updated_project = await db.execute(
        select(Project)
        .options(
            # 🌟 ALTERAÇÃO AQUI: Mudamos de vírgula para um ponto (.) encadeando o selectinload
            selectinload(Project.work_groups).selectinload(WorkGroup.members),
            selectinload(Project.countries),
            selectinload(Project.languages),
            selectinload(Project.members).joinedload(ProjectUser.user)
        )
        .where(Project.id == project_id)
    )
    return updated_project.scalar_one()

    #await db.refresh(project)
    #return project

@router.delete("/{project_id}", status_code=204)
async def delete_project(
    project_id: str,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """Only admin can delete. Reviewer/arbiter never have access to this endpoint (blocked by require_role)."""
    result = await db.execute(select(Project).where(Project.id == project_id))
    project = result.scalar_one_or_none()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    await log_audit(db, user.id, "delete", "project", project_id)
    await db.delete(project)
    await db.commit()


@router.post("/{project_id}/members", response_model=MemberOut, status_code=201)
async def add_member(
    project_id: str,
    payload: MemberAdd,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    # 1. Busca o usuário pelo e-mail
    result = await db.execute(select(User).where(User.email == payload.user_email))
    invitee = result.scalar_one_or_none()
    if not invitee:
        raise HTTPException(status_code=404, detail="User with this email not found")

    # 2. Salva estritamente na tabela do Projeto (ProjectUser)
    member = ProjectUser(project_id=project_id, user_id=invitee.id, role=payload.role)
    db.add(member)

    # 3. Log de auditoria limpo (sem referências a grupos)
    await log_audit(
        db, 
        user.id, 
        "add_member", 
        "project_user", 
        project_id,
        data_after={"user_email": payload.user_email, "role": payload.role.value}
    )
    
    await db.commit()

    # 4. Retorna o membro atualizado com os dados do usuário carregados
    refreshed_member = await db.execute(
        select(ProjectUser)
        .options(joinedload(ProjectUser.user))
        .where(ProjectUser.project_id == project_id, ProjectUser.user_id == invitee.id)
    )
    return refreshed_member.scalar_one()


@router.get("/{project_id}/members", response_model=List[MemberOut])
async def list_members(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not getattr(user, "is_admin", False):
        role = await get_role_in_project(project_id, user, db)
        if role is None:
            raise HTTPException(status_code=403, detail="No access to this project")

    result = await db.execute(
        select(ProjectUser)
        .options(joinedload(ProjectUser.user)) # Supondo que a relation se chame 'user'
        .where(ProjectUser.project_id == project_id)
    )
    return result.scalars().all()

@router.delete("/{project_id}/members/{user_id}", status_code=204)
async def remove_project_member(
    project_id: str,  # 🌟 O nome precisa ser exatamente igual ao parâmetro da rota para o require_role funcionar!
    user_id: str,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),  # Agora ele vai validar corretamente seu acesso de Admin neste projeto
    db: AsyncSession = Depends(get_db),
):
    # Busca o vínculo do usuário diretamente no projeto
    result = await db.execute(
        select(ProjectUser).where(
            ProjectUser.project_id == project_id,
            ProjectUser.user_id == user_id
        )
    )
    member_link = result.scalar_one_or_none()
    
    if not member_link:
        raise HTTPException(status_code=404, detail="Member not found in this project")

    # Registra na auditoria e remove
    await log_audit(
        db, 
        user.id, 
        "remove_member", 
        "project_user", 
        project_id, 
        data_before={"removed_user_id": user_id}
    )
    
    await db.delete(member_link)
    await db.commit()