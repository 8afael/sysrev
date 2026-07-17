from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.models import Country, Language
from app.schemas.metadata_schema import CountryOut, LanguageOut
from app.core.deps import get_current_user  # Opcional, remova se quiser a rota pública

router = APIRouter(prefix="/metadata", tags=["metadata"])

@router.get("/countries", response_model=List[CountryOut])
async def list_countries(
    db: AsyncSession = Depends(get_db),
    # _user = Depends(get_current_user)  # Ative se quiser exigir login para listar
):
    result = await db.execute(select(Country).order_by(Country.name))
    return result.scalars().all()


@router.get("/languages", response_model=List[LanguageOut])
async def list_languages(
    db: AsyncSession = Depends(get_db),
    # _user = Depends(get_current_user)  # Ative se quiser exigir login para listar
):
    result = await db.execute(select(Language).order_by(Language.name))
    return result.scalars().all()