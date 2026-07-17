from uuid import UUID
from pydantic import BaseModel, ConfigDict

class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str | None = None
    email: str
    active: bool
    preferred_language: str | None = None
    institution: str | None = None
    country: str | None = None