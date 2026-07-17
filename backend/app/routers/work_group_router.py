from uuid import UUID
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.models import User
from app.schemas.work_group_schema import (
    WorkGroupCreate,
    WorkGroupUpdate,
    WorkGroupOut,
    WorkGroupMemberOut,
    WorkGroupSimpleOut,
    
)
from app.services.work_group_service import WorkGroupService

router = APIRouter(prefix="/work-groups", tags=["work-groups"])

def get_service(db: AsyncSession = Depends(get_db)) -> WorkGroupService:
    return WorkGroupService(db)


@router.post("", response_model=WorkGroupOut, status_code=status.HTTP_201_CREATED)
async def create_work_group(
    payload: WorkGroupCreate,
    service: WorkGroupService = Depends(get_service),
    current_user: User = Depends(get_current_user),
):
    return await service.create(payload, current_user)


@router.get("/by-project/{project_id}", response_model=list[WorkGroupOut])
async def list_by_project(
    project_id: UUID,
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    return await service.list_by_project(project_id)


@router.get("/{group_id}", response_model=WorkGroupOut)
async def get_work_group(
    group_id: UUID,
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    return await service.get(group_id)


@router.patch("/{group_id}", response_model=WorkGroupOut)
async def update_work_group(
    group_id: UUID,
    payload: WorkGroupUpdate,
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    return await service.update(group_id, payload)


@router.delete("/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_work_group(
    group_id: UUID,
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    await service.delete(group_id)


@router.post(
    "/{group_id}/members/{project_user_id}",
    response_model=WorkGroupMemberOut,
    status_code=status.HTTP_201_CREATED,
)
async def add_member(
    group_id: UUID,
    project_user_id: UUID,
    service: WorkGroupService = Depends(get_service),
    current_user: User = Depends(get_current_user),
):
    return await service.add_member(group_id, project_user_id, current_user)


@router.delete(
    "/{group_id}/members/{project_user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def remove_member(
    group_id: UUID,
    project_user_id: UUID,
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    await service.remove_member(group_id, project_user_id)


@router.get("", response_model=list[WorkGroupOut])
async def list_all_work_groups(
    service: WorkGroupService = Depends(get_service),
    _: User = Depends(get_current_user),
):
    return await service.list_all()