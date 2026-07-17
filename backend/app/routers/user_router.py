from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.models import User  # Substitua pelo caminho correto do seu modelo de Usuário
from app.schemas.user_schema import UserOut

router = APIRouter(prefix="/users", tags=["users"])

@router.get("", response_model=list[UserOut])
async def list_users(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user), 
):
    query = select(User).order_by(User.name)
    result = await db.execute(query)
    users = result.scalars().all()
    return users