from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.models import User, ProjectUser
from app.models.enums import ProjectRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    user_id = decode_access_token(token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired credentials",
        )
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid user")
    return user


async def get_role_in_project(
    project_id: str,
    user: User,
    db: AsyncSession,
) -> ProjectRole | None:
    result = await db.execute(
        select(ProjectUser.role).where(
            ProjectUser.project_id == project_id,
            ProjectUser.user_id == user.id,
        )
    )
    row = result.scalar_one_or_none()
    return row


# def require_role(*allowed_roles: ProjectRole):
#     """Dependency factory: ensures that the user has one of the roles in the project specified via the `project_id` path param."""

#     async def checker(
#         project_id: str,
#         user: User = Depends(get_current_user),
#         db: AsyncSession = Depends(get_db),
#     ):
#         role = await get_role_in_project(project_id, user, db)
#         if role is None or role not in allowed_roles:
#             raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="You do not have permission for this action in this project",
#             )
#         return role

#     return checker

# def require_role(*allowed_roles: ProjectRole):
#     """Garante que o usuário tenha um dos papéis no projeto OU seja um Admin global do sistema."""

#     async def checker(
#         project_id: str,
#         user: User = Depends(get_current_user),
#         db: AsyncSession = Depends(get_db),
#     ):
#         # 🌟 SEGUNDO A NOVA REGRA: Se o usuário for Admin Global do sistema,
#         # ele ignora as restrições e passa direto!
#         # Ajuste 'is_admin' para a propriedade real do seu model User (ex: user.is_admin ou user.role == 'admin')
#         if getattr(user, "is_admin", False) or getattr(user, "role", "") == "admin":
#             return ProjectRole.admin  # Retorna o nível mais alto de permissão

#         role = await get_role_in_project(project_id, user, db)
#         if role is None or role not in allowed_roles:
#             raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="You do not have permission for this action in this project",
#             )
#         return role

#     return checker

def require_role(*allowed_roles: ProjectRole):
    async def checker(
        project_id: str,
        user: User = Depends(get_current_user),
        db: AsyncSession = Depends(get_db),
    ):
        # 🌟 Agora 'user.is_admin' vai retornar True para você!
        if getattr(user, "is_admin", False):
            return ProjectRole.admin

        role = await get_role_in_project(project_id, user, db)
        if role is None or role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission for this action in this project",
            )
        return role

    return checker