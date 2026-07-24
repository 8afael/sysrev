from pydantic import BaseModel, Field
from uuid import UUID
from typing import List
from app.models.enums import AssignmentRole


class AssignmentMemberIn(BaseModel):
    user_id: UUID
    role: AssignmentRole = AssignmentRole.reviewer1


class AssignmentBulkDocumentUpdate(BaseModel):
    document_id: UUID
    assigned_members: List[AssignmentMemberIn] = Field(default_factory=list)


class AssignmentBulkUpdateIn(BaseModel):
    documents: List[AssignmentBulkDocumentUpdate]


class AssignmentBulkUpdateOut(BaseModel):
    updated_documents: int
    created_assignments: int
    deleted_assignments: int