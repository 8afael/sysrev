from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict


class WorkGroupMemberOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    project_user_id: UUID
    role: str | None = None
    added_at: datetime


class WorkGroupCreate(BaseModel):
    # 🌟 ALTERADO: Agora aceita uma lista de projetos (ou lista vazia se for criado solto)
    project_ids: list[UUID] = Field(default_factory=list, description="Lista de IDs de projetos para associar o grupo")
    name: str = Field(min_length=1, max_length=150)
    description: str | None = None
    member_ids: list[UUID] = Field(default_factory=list, min_length=1, max_length=4)

class WorkGroupUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=150)
    description: str | None = None
    is_active: bool | None = None
    project_ids: list[UUID] | None = None 

class WorkGroupOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    # ❌ REMOVIDO: project_id: UUID (não existe mais essa coluna na tabela)
    name: str
    description: str | None
    is_active: bool
    created_at: datetime
    members: list[WorkGroupMemberOut] = []
    
    # 🌟 ADICIONADO: Retorna os IDs dos projetos vinculados usando uma propriedade calculada (Pydantic validator) ou relationship do SQLAlchemy
    # Se você configurou `projects` como relationship no model, podemos retornar apenas os IDs para manter o schema leve:
    project_ids: list[UUID] = []

    # Helper para mapear automaticamente o relacionamento muitos-para-muitos do SQLAlchemy para uma lista de IDs
    @classmethod
    def model_validate(cls, obj, **kwargs):
        data = super().model_validate(obj, **kwargs)
        if hasattr(obj, 'projects'):
            data.project_ids = [p.id for p in obj.projects]
        return data
    
class WorkGroupSimpleOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    name: str
    description: str | None = None
    is_active: bool