from typing import Optional, Any, Dict, List
from datetime import datetime
from pydantic import BaseModel

from app.models.enums import (
    ProjectType, FieldGroup, SubmissionStatus, DocumentPhase,
    AssignmentMethod, AssignmentRole, AssignmentStatus, Decision, ConflictStatus,
)


# ---------- Form Schema (versioned form) ----------
class FormSchemaCreate(BaseModel):
    protocol: ProjectType
    group: FieldGroup
    name: str
    fields_json: Dict[str, Any]  # e.g.: {"fields": [{"id": "topic", "type": "text", "required": true}, ...]}


class FormSchemaOut(BaseModel):
    id: str
    project_id: str
    protocol: ProjectType
    group: FieldGroup
    version: int
    name: str
    fields_json: Dict[str, Any]
    active: bool
    created_at: datetime

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


class DocumentOut(BaseModel):
    id: str
    project_id: str
    title: str
    source_type: Optional[str]
    submission_status: SubmissionStatus
    duplicate_flag: bool
    phase: DocumentPhase
    created_at: datetime

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


class AssignmentOut(BaseModel):
    id: str
    document_id: str
    reviewer_id: str
    role: AssignmentRole
    status: AssignmentStatus
    deadline: Optional[datetime]
    created_at: datetime

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