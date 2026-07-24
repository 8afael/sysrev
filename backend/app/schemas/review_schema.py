from typing import Optional, Any, Dict, List
from datetime import datetime
from pydantic import BaseModel, Field

from app.models.enums import (
    ProjectType, FieldGroup, SubmissionStatus, DocumentPhase,
    AssignmentMethod, AssignmentRole, AssignmentStatus, Decision, ConflictStatus,
)

# ---------- Form Schema (versioned form) ----------
class FormSchemaCreate(BaseModel):
    title: str = Field(
        default="Untitled Form", 
        max_length=255, 
        description="Título do formulário de extração"
    )
    description: Optional[str] = Field(
        default=None, 
        max_length=1000, 
        description="Instruções gerais para os revisores"
    )
    structure: Dict[str, Any] = Field(
        default_factory=dict,
        description="JSON estruturado contendo as seções, perguntas, opções e validações."
    )


class FormSchemaOut(BaseModel):
    id: str
    project_id: str
    title: str
    description: Optional[str] = None
    structure: Dict[str, Any]
    created_at: datetime

    class Config:
        from_attributes = True


class FormResponseCreate(BaseModel):
    assignment_id: Optional[str] = Field(
        default=None, 
        description="ID da atribuição/documento sendo revisado, se houver"
    )
    answers: Dict[str, Any] = Field(
        default_factory=dict,
        description="Objeto chave-valor com as respostas (ex: {'q1': 'Sim', 'q2': ['Opção A']})"
    )


class FormResponseOut(BaseModel):
    id: str
    form_schema_id: str
    assignment_id: Optional[str] = None
    reviewer_id: str
    answers: Dict[str, Any]
    submitted_at: datetime

    class Config:
        from_attributes = True


# ---------- Document ----------
class DocumentCreate(BaseModel):
    title: str
    source_type: Optional[str] = None
    file_url: Optional[str] = None
    external_reference: Optional[str] = None
    copyright_status: Optional[str] = "unknown"
    access_restriction: Optional[str] = "restricted"
    language: Optional[str] = None
    country_region: Optional[str] = None
    extra_metadata: Dict[str, Any] = {}

class ReviewerSimpleOut(BaseModel):
    id: str
    name: str
    email: str

    class Config:
        from_attributes = True

class AssignmentInDocumentOut(BaseModel):
    id: str
    reviewer_id: str
    role: Optional[AssignmentRole] = None
    status: AssignmentStatus
    reviewer: Optional[ReviewerSimpleOut] = None

    class Config:
        from_attributes = True


class DocumentOut(BaseModel):
    id: str
    project_id: str
    title: str
    source_type: Optional[str]
    submission_status: SubmissionStatus
    duplicate_flag: bool
    phase: DocumentPhase
    created_at: datetime

    assignments: List[AssignmentInDocumentOut] = []

    class Config:
        from_attributes = True


# ---------- Assignment ----------
class AssignmentCreate(BaseModel):
    document_id: str
    reviewer_id: str
    form_schema_id: Optional[str] = None
    role: AssignmentRole = AssignmentRole.reviewer1
    method: AssignmentMethod = AssignmentMethod.manual
    deadline: Optional[datetime] = None


class DocumentBrief(BaseModel):
    id: str
    title: str  # ajustar pro nome real do atributo no seu model Document

    class Config:
        from_attributes = True  

class AssignmentOut(BaseModel):
    id: str
    document_id: str
    reviewer_id: str
    role: AssignmentRole
    status: AssignmentStatus
    deadline: Optional[datetime]
    created_at: datetime
    document: Optional[DocumentBrief] = None 

    class Config:
        from_attributes = True


# ---------- Review ----------
class ReviewUpdate(BaseModel):
    answers_json: Dict[str, Any] = {}
    decision: Optional[Decision] = None
    exclusion_reason: Optional[str] = None
    confidence: Optional[int] = None
    finalized: bool = False


class ReviewOut(BaseModel):
    id: str
    assignment_id: str
    answers_json: Dict[str, Any]
    decision: Optional[Decision]
    finalized: bool
    updated_at: datetime

    class Config:
        from_attributes = True


# ---------- Conflict ----------
class ConflictResolve(BaseModel):
    final_decision: Decision
    arbiter_justification: str


class ConflictOut(BaseModel):
    id: str
    document_id: str
    status: ConflictStatus
    final_decision: Optional[Decision]
    created_at: datetime

    class Config:
        from_attributes = True


# ---------- Dashboard ----------
class DashboardAdminOut(BaseModel):
    total_projects: int
    projects_in_progress: int
    total_documents: int
    documents_by_phase: Dict[str, int]
    open_conflicts: int
    pending_assignments: int


class DashboardReviewerOut(BaseModel):
    total_assignments: int
    pending: int
    in_progress: int
    completed: int
    upcoming_deadlines: List[Dict[str, Any]]





