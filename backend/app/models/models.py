import uuid
from datetime import datetime

from sqlalchemy import (
    Column, String, Boolean, DateTime, ForeignKey, Table, Text, Integer,
    Enum as SAEnum, JSON, ARRAY, TypeDecorator
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.enums import (
    ProjectRole, ProjectType, ReviewMode, ProjectStatus, FieldGroup,
    SubmissionStatus, DocumentPhase, AssignmentMethod, AssignmentRole,
    AssignmentStatus, Decision, ConflictStatus,
)


def gen_uuid():
    return str(uuid.uuid4())


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    active = Column(Boolean, default=True)
    preferred_language = Column(String(10), default="pt-BR")
    created_at = Column(DateTime, default=datetime.utcnow)

    country = Column(String(255), nullable=True)
    institution = Column(String(255), nullable=True)
    
    is_active = Column(Boolean, default=True)

    is_admin = Column(Boolean, default=False)

    memberships = relationship("ProjectUser", back_populates="user")

project_work_groups = Table(
    "project_work_groups",
    Base.metadata,
    Column("project_id", UUID(as_uuid=False), ForeignKey("projects.id", ondelete="CASCADE"), primary_key=True),
    Column("work_group_id", UUID(as_uuid=False), ForeignKey("work_groups.id", ondelete="CASCADE"), primary_key=True),
    Column("associated_at", DateTime, default=datetime.utcnow)
)

# 2. Tabela Associativa: Projetos <-> Países (CORRIGIDA)
project_countries = Table(
    "project_countries",
    Base.metadata,
    Column("project_id", UUID(as_uuid=False), ForeignKey("projects.id", ondelete="CASCADE"), primary_key=True),
    Column("country_id", Integer, ForeignKey("countries.id", ondelete="CASCADE"), primary_key=True)
)

# 3. Tabela Associativa: Projetos <-> Idiomas (CORRIGIDA)
project_languages = Table(
    "project_languages",
    Base.metadata,
    # 🌟 CORRIGIDO: project_id alterado de Integer para UUID(as_uuid=False) para bater com projects.id
    Column("project_id", UUID(as_uuid=False), ForeignKey("projects.id", ondelete="CASCADE"), primary_key=True),
    Column("language_id", Integer, ForeignKey("languages.id", ondelete="CASCADE"), primary_key=True)
)


class Country(Base):
    __tablename__ = "countries"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    code = Column(String(3))  # Ex: BRA, USA, GBR

    projects = relationship("Project", secondary=project_countries, back_populates="countries")


class Language(Base):
    __tablename__ = "languages"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)
    code = Column(String(5))  # Ex: pt-BR, en-US

    projects = relationship("Project", secondary=project_languages, back_populates="languages")


class Project(Base):
    __tablename__ = "projects"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    type = Column(SAEnum(ProjectType), nullable=False)
    lead_institution = Column(String(255))
    countries = Column(ARRAY(String), default=list)
    languages = Column(ARRAY(String), default=list)
    review_mode = Column(SAEnum(ReviewMode), default=ReviewMode.collaborative)
    status = Column(SAEnum(ProjectStatus), default=ProjectStatus.planning)
    created_by = Column(UUID(as_uuid=False), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    document_provider = Column(String(20), default="admin")
    member_instructions = Column(Text, nullable=True)

    members = relationship("ProjectUser", back_populates="project", cascade="all, delete-orphan")
    documents = relationship("Document", back_populates="project", cascade="all, delete-orphan")
    form_schemas = relationship("FormSchema", back_populates="project", cascade="all, delete-orphan")
    
    work_groups = relationship("WorkGroup", secondary=project_work_groups, back_populates="projects")
    countries = relationship("Country", secondary=project_countries, back_populates="projects")
    languages = relationship("Language", secondary=project_languages, back_populates="projects")

class WorkGroup(Base):
    __tablename__ = "work_groups"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    name = Column(String(150), nullable=False)
    description = Column(Text)
    created_by = Column(UUID(as_uuid=False), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_active = Column(Boolean, default=True)

    # Relacionamentos
    projects = relationship("Project", secondary=project_work_groups, back_populates="work_groups")
    members = relationship("WorkGroupMember", back_populates="work_group", cascade="all, delete-orphan")


class WorkGroupMember(Base):
    __tablename__ = "work_group_members"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    work_group_id = Column(UUID(as_uuid=False), ForeignKey("work_groups.id", ondelete="CASCADE"), nullable=False)
    project_user_id = Column(UUID(as_uuid=False), ForeignKey("project_users.id", ondelete="CASCADE"), nullable=False)
    role = Column(String(50))  # Ex: "coordenador", "pesquisador"
    added_at = Column(DateTime, default=datetime.utcnow)
    added_by = Column(UUID(as_uuid=False), ForeignKey("users.id"))

    work_group = relationship("WorkGroup", back_populates="members")


class ProjectUser(Base):
    __tablename__ = "project_users"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey("projects.id"), nullable=False)
    user_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=False)
    role = Column(SAEnum(ProjectRole), nullable=False)
    invited_at = Column(DateTime, default=datetime.utcnow)
    accepted = Column(Boolean, default=True)

    project = relationship("Project", back_populates="members")
    user = relationship("User", back_populates="memberships")


class FormSchema(Base):
    """Versioned analysis form. Never overwritten: a new edit = a new version."""
    __tablename__ = "form_schemas"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey("projects.id"), nullable=False)
    protocol = Column(SAEnum(ProjectType), nullable=False)  # scientific(prisma) | technical(gt2)
    group = Column(SAEnum(FieldGroup), nullable=False)
    version = Column(Integer, default=1)
    name = Column(String(255), nullable=False)
    fields_json = Column(JSON, nullable=False)  # dynamic field structure
    active = Column(Boolean, default=True)
    created_by = Column(UUID(as_uuid=False), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    project = relationship("Project", back_populates="form_schemas")


class Document(Base):
    __tablename__ = "documents"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey("projects.id"), nullable=False)
    title = Column(String(500), nullable=False)
    source_type = Column(String(100))  # article, report, thesis, etc.
    file_url = Column(String(1000))              # direct upload
    external_reference = Column(String(1000))    # URL/repository/DOI
    copyright_status = Column(String(50), default="unknown")
    access_restriction = Column(String(50), default="restricted")
    language = Column(String(10))
    country_region = Column(String(100))
    submission_status = Column(SAEnum(SubmissionStatus), default=SubmissionStatus.registered)
    duplicate_flag = Column(Boolean, default=False)
    phase = Column(SAEnum(DocumentPhase), default=DocumentPhase.identification)
    extra_metadata = Column(JSON, default=dict)  # renamed from metadata_json (reserved name)
    created_at = Column(DateTime, default=datetime.utcnow)

    source_type = Column(String(100))
    drive_file_id = Column(String(255), nullable=True, index=True)
    file_size = Column(Integer, nullable=True)

    project = relationship("Project", back_populates="documents")
    assignments = relationship("Assignment", back_populates="document", cascade="all, delete-orphan")
    conflicts = relationship("Conflict", back_populates="document", cascade="all, delete-orphan")


class Assignment(Base):
    __tablename__ = "assignments"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    document_id = Column(UUID(as_uuid=False), ForeignKey("documents.id"), nullable=False)
    reviewer_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=False)
    form_schema_id = Column(UUID(as_uuid=False), ForeignKey("form_schemas.id"))
    role = Column(SAEnum(AssignmentRole), default=AssignmentRole.reviewer1)
    method = Column(SAEnum(AssignmentMethod), default=AssignmentMethod.manual)
    status = Column(SAEnum(AssignmentStatus), default=AssignmentStatus.pending)
    deadline = Column(DateTime, nullable=True)
    assigned_by = Column(UUID(as_uuid=False), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    document = relationship("Document", back_populates="assignments")
    review = relationship("Review", back_populates="assignment", uselist=False, cascade="all, delete-orphan")


class Review(Base):
    __tablename__ = "reviews"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    assignment_id = Column(UUID(as_uuid=False), ForeignKey("assignments.id"), nullable=False, unique=True)
    answers_json = Column(JSON, default=dict)
    decision = Column(SAEnum(Decision), nullable=True)
    exclusion_reason = Column(Text, nullable=True)
    confidence = Column(Integer, nullable=True)  # 1-5
    review_round = Column(Integer, default=1)
    finalized = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    assignment = relationship("Assignment", back_populates="review")


class Conflict(Base):
    __tablename__ = "conflicts"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    document_id = Column(UUID(as_uuid=False), ForeignKey("documents.id"), nullable=False)
    review1_id = Column(UUID(as_uuid=False), ForeignKey("reviews.id"))
    review2_id = Column(UUID(as_uuid=False), ForeignKey("reviews.id"))
    status = Column(SAEnum(ConflictStatus), default=ConflictStatus.open)
    arbiter_id = Column(UUID(as_uuid=False), ForeignKey("users.id"), nullable=True)
    final_decision = Column(SAEnum(Decision), nullable=True)
    arbiter_justification = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)

    document = relationship("Document", back_populates="conflicts")

class ForceString(TypeDecorator):
    impl = String(100)
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is not None:
            return str(value) # Converte UUID, int ou qualquer objeto em string automaticamente
        return value
    
class AuditLog(Base):
    __tablename__ = "audit_log"

    # Usando o as_uuid=True nos IDs reais ajuda a trabalhar com objetos UUID nativos
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    action = Column(String(100), nullable=False)
    entity = Column(String(100), nullable=False)
    
    # 🌟 A MÁGICA AQUI: O banco continua sendo String(100), mas aceita UUID no código!
    entity_id = Column(ForceString, nullable=True)
    
    data_before = Column(JSON, nullable=True)
    data_after = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class PromptTemplate(Base):
    __tablename__ = "prompt_templates"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey("projects.id"), nullable=False)
    name = Column(String(255), nullable=False)
    purpose = Column(String(50))  # screening | similarity | classification | assignment
    prompt_text = Column(Text, nullable=False)
    active = Column(Boolean, default=False)


class AIRequest(Base):
    __tablename__ = "ai_requests"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey("projects.id"), nullable=False)
    prompt_template_id = Column(UUID(as_uuid=False), ForeignKey("prompt_templates.id"), nullable=True)
    input_hash = Column(String(255))
    response = Column(JSON, nullable=True)
    suggestion = Column(String(50), nullable=True)
    user_action = Column(String(50), nullable=True)  # accepted | overridden
    user_id = Column(UUID(as_uuid=False), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)