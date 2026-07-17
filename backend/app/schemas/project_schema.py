from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel
from uuid import UUID
from app.models.enums import ProjectType, ReviewMode, ProjectStatus, ProjectRole
from app.schemas.work_group_schema import WorkGroupOut
from app.schemas.metadata_schema import CountryOut as CountryProjectOut, LanguageOut as LanguageProjectOut

class CountryProjectOut(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class LanguageProjectOut(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class ProjectMemberInput(BaseModel):
    user_id: UUID
    role: ProjectRole

    class Config:
        from_attributes = True

class ProjectCreate(BaseModel):
    title: str
    description: Optional[str] = None
    type: ProjectType
    lead_institution: Optional[str] = None
    countries: List[str] = []
    languages: List[str] = []
    review_mode: ReviewMode = ReviewMode.collaborative
    
    work_group_ids: Optional[list[UUID]] = None
    country_ids: Optional[list[int]] = None    
    language_ids: Optional[list[int]] = None
    
    members: Optional[list[ProjectMemberInput]] = []

class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[ProjectStatus] = None
    review_mode: Optional[ReviewMode] = None

    work_group_ids: Optional[list[UUID]] = None
    country_ids: Optional[list[int]] = None     
    language_ids: Optional[list[int]] = None

    members: Optional[list[ProjectMemberInput]] = None

class ProjectOut(BaseModel):
    id: str
    title: str
    description: Optional[str]
    type: ProjectType
    lead_institution: Optional[str]
    countries: List[str]
    work_groups: list[WorkGroupOut] = []
    languages: List[str]
    review_mode: ReviewMode
    status: ProjectStatus
    created_at: datetime

    countries: List[CountryProjectOut] = []
    languages: List[LanguageProjectOut] = []

    class Config:
        from_attributes = True

class MemberAdd(BaseModel):
    user_email: str
    role: ProjectRole
    work_group_id: Optional[UUID] = None


class MemberOut(BaseModel):
    id: str
    user_id: str
    role: ProjectRole
    accepted: bool

    class Config:
        from_attributes = True