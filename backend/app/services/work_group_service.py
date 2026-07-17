from uuid import UUID
from fastapi import Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.core.database import get_db

from app.models.models import (
    WorkGroup,
    WorkGroupMember,
    ProjectUser,
    Project,
    User,
)
from app.schemas.work_group_schema import WorkGroupCreate, WorkGroupUpdate

MIN_MEMBERS = 1


class WorkGroupService:
    def __init__(self, db: AsyncSession = Depends(get_db)):
        self.db = db

    # ---------- helpers ----------
    async def _get_group_or_404(self, group_id: UUID) -> WorkGroup:
        result = await self.db.execute(
            select(WorkGroup)
            .where(WorkGroup.id == group_id)
            .options(selectinload(WorkGroup.members))
        )
        group = result.scalar_one_or_none()
        if not group:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Work group not found")
        return group

    async def _validate_project(self, project_id: UUID) -> None:
        exists = await self.db.scalar(
            select(Project.id).where(Project.id == project_id)
        )
        if not exists:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Project not found")
        
    

    async def _validate_project_users(
        self, project_id: UUID, member_ids: list[UUID]
    ) -> None:
        """Confere que todos os project_users existem e pertencem ao projeto."""
        unique_ids = set(member_ids)
        if len(unique_ids) != len(member_ids):
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Duplicate members are not allowed"
            )

        result = await self.db.execute(
            select(ProjectUser.id).where(
                ProjectUser.id.in_(unique_ids),
                ProjectUser.project_id == project_id,
            )
        )
        found = {row[0] for row in result.all()}
        missing = unique_ids - found
        if missing:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Project users not found or not linked to project: {missing}",
            )

    # ---------- CRUD ----------
    async def list_all(self) -> list[WorkGroup]:
        result = await self.db.execute(
            select(WorkGroup)
            .options(selectinload(WorkGroup.members))
            .order_by(WorkGroup.name.asc())
        )
        return list(result.scalars().all())

    async def create(self, payload: WorkGroupCreate, current_user: User) -> WorkGroup:
        await self._validate_project(payload.project_id)
        await self._validate_project_users(payload.project_id, payload.member_ids)

        group = WorkGroup(
            project_id=payload.project_id,
            name=payload.name,
            description=payload.description,
            created_by=current_user.id,  # Mantemos apenas o rastro de QUEM criou na auditoria
        )
        self.db.add(group)
        await self.db.flush()  # Garante a geração do group.id

        # 🌟 SALVA APENAS OS IDS SELECIONADOS NO FRONTEND
        # Removemos qualquer lógica que injetava o 'current_user.id' automaticamente aqui!
        for pu_id in payload.member_ids:
            self.db.add(
                WorkGroupMember(
                    work_group_id=group.id,
                    project_user_id=pu_id,
                    added_by=current_user.id,
                )
            )

        await self.db.commit()
        return await self._get_group_or_404(group.id)

    # async def create(self, payload: WorkGroupCreate, current_user: User) -> WorkGroup:
    #     await self._validate_project(payload.project_id)
    #     await self._validate_project_users(payload.project_id, payload.member_ids)

    #     group = WorkGroup(
    #         project_id=payload.project_id,
    #         name=payload.name,
    #         description=payload.description,
    #         created_by=current_user.id,
    #     )
    #     self.db.add(group)
    #     await self.db.flush()  # garante group.id

    #     for pu_id in payload.member_ids:
    #         self.db.add(
    #             WorkGroupMember(
    #                 work_group_id=group.id,
    #                 project_user_id=pu_id,
    #                 added_by=current_user.id,
    #             )
    #         )

    #     await self.db.commit()
    #     return await self._get_group_or_404(group.id)

    async def list_by_project(self, project_id: UUID) -> list[WorkGroup]:
        result = await self.db.execute(
            select(WorkGroup)
            .where(WorkGroup.projects.any(id=project_id))
            .options(selectinload(WorkGroup.members))
            .order_by(WorkGroup.created_at.desc())
        )
        return list(result.scalars().all())

    async def get(self, group_id: UUID) -> WorkGroup:
        return await self._get_group_or_404(group_id)

    async def update(self, group_id: UUID, payload: WorkGroupUpdate) -> WorkGroup:
        group = await self._get_group_or_404(group_id)
        data = payload.model_dump(exclude_unset=True)
        for field, value in data.items():
            setattr(group, field, value)
        await self.db.commit()
        return await self._get_group_or_404(group.id)

    async def delete(self, group_id: UUID) -> None:
        group = await self._get_group_or_404(group_id)
        await self.db.delete(group)
        await self.db.commit()

    # ---------- membros ----------
    async def add_member(
        self, group_id: UUID, project_user_id: UUID, current_user: User
    ) -> WorkGroupMember:
        group = await self._get_group_or_404(group_id)

        # 🌟 Validação de máximo removida conforme solicitado!

        await self._validate_project_users(group.project_id, [project_user_id])

        already = await self.db.scalar(
            select(WorkGroupMember.id).where(
                WorkGroupMember.work_group_id == group_id,
                WorkGroupMember.project_user_id == project_user_id,
            )
        )
        if already:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "User is already in this group"
            )

        member = WorkGroupMember(
            work_group_id=group_id,
            project_user_id=project_user_id,
            added_by=current_user.id,
        )
        self.db.add(member)
        await self.db.commit()
        await self.db.refresh(member)
        return member

    async def remove_member(self, group_id: UUID, project_user_id: UUID) -> None:
        result = await self.db.execute(
            select(WorkGroupMember).where(
                WorkGroupMember.work_group_id == group_id,
                WorkGroupMember.project_user_id == project_user_id,
            )
        )
        member = result.scalar_one_or_none()
        if not member:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Member not found in group")

        count = await self.db.scalar(
            select(func.count(WorkGroupMember.id)).where(
                WorkGroupMember.work_group_id == group_id
            )
        )
        if count <= MIN_MEMBERS:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                f"Work group must have at least {MIN_MEMBERS} member(s)",
            )

        await self.db.delete(member)
        await self.db.commit()

# from uuid import UUID
# from fastapi import Depends, HTTPException, status
# from sqlalchemy import select, func
# from sqlalchemy.ext.asyncio import AsyncSession
# from sqlalchemy.orm import selectinload
# from app.core.database import get_db

# from app.models.models import (
#     WorkGroup,
#     WorkGroupMember,
#     ProjectUser,
#     Project,
#     User,
# )
# from app.schemas.work_group_schema import WorkGroupCreate, WorkGroupUpdate

# MIN_MEMBERS = 1
# MAX_MEMBERS = 4


# class WorkGroupService:
#     def __init__(self, db: AsyncSession = Depends(get_db)):
#         self.db = db

#     # ---------- helpers ----------
#     async def _get_group_or_404(self, group_id: UUID) -> WorkGroup:
#         result = await self.db.execute(
#             select(WorkGroup)
#             .where(WorkGroup.id == group_id)
#             .options(selectinload(WorkGroup.members))
#         )
#         group = result.scalar_one_or_none()
#         if not group:
#             raise HTTPException(status.HTTP_404_NOT_FOUND, "Work group not found")
#         return group

#     async def _validate_project(self, project_id: UUID) -> None:
#         exists = await self.db.scalar(
#             select(Project.id).where(Project.id == project_id)
#         )
#         if not exists:
#             raise HTTPException(status.HTTP_404_NOT_FOUND, "Project not found")
        
    

#     async def _validate_project_users(
#         self, project_id: UUID, member_ids: list[UUID]
#     ) -> None:
#         """Confere que todos os project_users existem e pertencem ao projeto."""
#         unique_ids = set(member_ids)
#         if len(unique_ids) != len(member_ids):
#             raise HTTPException(
#                 status.HTTP_400_BAD_REQUEST, "Duplicate members are not allowed"
#             )

#         result = await self.db.execute(
#             select(ProjectUser.id).where(
#                 ProjectUser.id.in_(unique_ids),
#                 ProjectUser.project_id == project_id,
#             )
#         )
#         found = {row[0] for row in result.all()}
#         missing = unique_ids - found
#         if missing:
#             raise HTTPException(
#                 status.HTTP_400_BAD_REQUEST,
#                 f"Project users not found or not linked to project: {missing}",
#             )

#     # ---------- CRUD ----------
#     async def list_all(self) -> list[WorkGroup]:
#         result = await self.db.execute(
#             select(WorkGroup)
#             .order_by(WorkGroup.name.asc())
#         )
#         return list(result.scalars().all())

#     async def create(self, payload: WorkGroupCreate, current_user: User) -> WorkGroup:
#         await self._validate_project(payload.project_id)
#         await self._validate_project_users(payload.project_id, payload.member_ids)

#         group = WorkGroup(
#             project_id=payload.project_id,
#             name=payload.name,
#             description=payload.description,
#             created_by=current_user.id,  # Mantemos apenas o rastro de QUEM criou na auditoria
#         )
#         self.db.add(group)
#         await self.db.flush()  # Garante a geração do group.id

#         # 🌟 SALVA APENAS OS IDS SELECIONADOS NO FRONTEND
#         # Removemos qualquer lógica que injetava o 'current_user.id' automaticamente aqui!
#         for pu_id in payload.member_ids:
#             self.db.add(
#                 WorkGroupMember(
#                     work_group_id=group.id,
#                     project_user_id=pu_id,
#                     added_by=current_user.id,
#                 )
#             )

#         await self.db.commit()
#         return await self._get_group_or_404(group.id)

#     # async def create(self, payload: WorkGroupCreate, current_user: User) -> WorkGroup:
#     #     await self._validate_project(payload.project_id)
#     #     await self._validate_project_users(payload.project_id, payload.member_ids)

#     #     group = WorkGroup(
#     #         project_id=payload.project_id,
#     #         name=payload.name,
#     #         description=payload.description,
#     #         created_by=current_user.id,
#     #     )
#     #     self.db.add(group)
#     #     await self.db.flush()  # garante group.id

#     #     for pu_id in payload.member_ids:
#     #         self.db.add(
#     #             WorkGroupMember(
#     #                 work_group_id=group.id,
#     #                 project_user_id=pu_id,
#     #                 added_by=current_user.id,
#     #             )
#     #         )

#     #     await self.db.commit()
#     #     return await self._get_group_or_404(group.id)

#     async def list_by_project(self, project_id: UUID) -> list[WorkGroup]:
#         result = await self.db.execute(
#             select(WorkGroup)
#             .where(WorkGroup.projects.any(id=project_id))
#             .options(selectinload(WorkGroup.members))
#             .order_by(WorkGroup.created_at.desc())
#         )
#         return list(result.scalars().all())

#     async def get(self, group_id: UUID) -> WorkGroup:
#         return await self._get_group_or_404(group_id)

#     async def update(self, group_id: UUID, payload: WorkGroupUpdate) -> WorkGroup:
#         group = await self._get_group_or_404(group_id)
#         data = payload.model_dump(exclude_unset=True)
#         for field, value in data.items():
#             setattr(group, field, value)
#         await self.db.commit()
#         return await self._get_group_or_404(group.id)

#     async def delete(self, group_id: UUID) -> None:
#         group = await self._get_group_or_404(group_id)
#         await self.db.delete(group)
#         await self.db.commit()

#     # ---------- membros ----------
#     async def add_member(
#         self, group_id: UUID, project_user_id: UUID, current_user: User
#     ) -> WorkGroupMember:
#         group = await self._get_group_or_404(group_id)

#         count = await self.db.scalar(
#             select(func.count(WorkGroupMember.id)).where(
#                 WorkGroupMember.work_group_id == group_id
#             )
#         )
#         if count >= MAX_MEMBERS:
#             raise HTTPException(
#                 status.HTTP_400_BAD_REQUEST,
#                 f"Work group cannot have more than {MAX_MEMBERS} members",
#             )

#         await self._validate_project_users(group.project_id, [project_user_id])

#         already = await self.db.scalar(
#             select(WorkGroupMember.id).where(
#                 WorkGroupMember.work_group_id == group_id,
#                 WorkGroupMember.project_user_id == project_user_id,
#             )
#         )
#         if already:
#             raise HTTPException(
#                 status.HTTP_400_BAD_REQUEST, "User is already in this group"
#             )

#         member = WorkGroupMember(
#             work_group_id=group_id,
#             project_user_id=project_user_id,
#             added_by=current_user.id,
#         )
#         self.db.add(member)
#         await self.db.commit()
#         await self.db.refresh(member)
#         return member

#     async def remove_member(self, group_id: UUID, project_user_id: UUID) -> None:
#         result = await self.db.execute(
#             select(WorkGroupMember).where(
#                 WorkGroupMember.work_group_id == group_id,
#                 WorkGroupMember.project_user_id == project_user_id,
#             )
#         )
#         member = result.scalar_one_or_none()
#         if not member:
#             raise HTTPException(status.HTTP_404_NOT_FOUND, "Member not found in group")

#         count = await self.db.scalar(
#             select(func.count(WorkGroupMember.id)).where(
#                 WorkGroupMember.work_group_id == group_id
#             )
#         )
#         if count <= MIN_MEMBERS:
#             raise HTTPException(
#                 status.HTTP_400_BAD_REQUEST,
#                 f"Work group must have at least {MIN_MEMBERS} member(s)",
#             )

#         await self.db.delete(member)
#         await self.db.commit()