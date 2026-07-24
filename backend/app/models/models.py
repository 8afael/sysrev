import uuid
from datetime import datetime

from sqlalchemy import (
    Column, String, Boolean, DateTime, ForeignKey, Table, Text, Integer,
    Enum as SAEnum, JSON, ARRAY, TypeDecorator, UniqueConstraint
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

    form_responses = relationship("FormResponse", back_populates="reviewer")

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
    __tablename__ = 'form_schemas'

    # Padronizado para UUID(as_uuid=False) e gen_uuid
    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    project_id = Column(UUID(as_uuid=False), ForeignKey('projects.id', ondelete='CASCADE'), nullable=False)
    title = Column(String(255), nullable=False, default="Untitled Form")
    description = Column(String(1000), nullable=True)
    # Guarda o layout: seções, perguntas, tipos, opções e regras de validação
    structure = Column(JSON, nullable=False, default=dict)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relacionamentos
    project = relationship("Project", back_populates="form_schemas")
    responses = relationship("FormResponse", back_populates="form_schema", cascade="all, delete-orphan")
    assignments = relationship("Assignment", back_populates="form_schema")


class FormResponse(Base):
    __tablename__ = 'form_responses'

    # Padronizado para UUID(as_uuid=False) e gen_uuid
    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    form_schema_id = Column(UUID(as_uuid=False), ForeignKey('form_schemas.id', ondelete='CASCADE'), nullable=False)
    assignment_id = Column(UUID(as_uuid=False), ForeignKey('assignments.id', ondelete='CASCADE'), nullable=True)
    reviewer_id = Column(UUID(as_uuid=False), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    
    # Guarda as respostas no formato: {"question_id_1": "Resposta", "question_id_2": ["Opção A", "Opção B"]}
    answers = Column(JSON, nullable=False, default=dict)
    submitted_at = Column(DateTime, default=datetime.utcnow)

    # Relacionamentos de Chave Estrangeira
    form_schema = relationship("FormSchema", back_populates="responses")
    assignment = relationship("Assignment", back_populates="form_responses")
    reviewer = relationship("User", back_populates="form_responses")

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
    submission_status = Column(SAEnum(SubmissionStatus, native_enum=True, create_type=False), 
                               default=SubmissionStatus.registered, 
                               nullable=True)
    duplicate_flag = Column(Boolean, default=False)
    phase = Column(SAEnum(DocumentPhase, native_enum=True, create_type=False), 
                   default=DocumentPhase.identification, 
                   nullable=True)
    extra_metadata = Column(JSON, default=dict)  # renamed from metadata_json (reserved name)
    created_at = Column(DateTime, default=datetime.utcnow)

    drive_file_id = Column(String(255), nullable=True, index=True)
    file_size = Column(Integer, nullable=True)

    project = relationship("Project", back_populates="documents")
    assignments = relationship("Assignment", back_populates="document", cascade="all, delete-orphan")
    conflicts = relationship("Conflict", back_populates="document", cascade="all, delete-orphan")


class Assignment(Base):
    __tablename__ = "assignments"

    id = Column(UUID(as_uuid=False), primary_key=True, default=gen_uuid)
    document_id = Column(UUID(as_uuid=False), ForeignKey("documents.id", ondelete="CASCADE"), nullable=False)
    reviewer_id = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    form_schema_id = Column(UUID(as_uuid=False), ForeignKey("form_schemas.id", ondelete="SET NULL"), nullable=True)
    
    role = Column(
        SAEnum(AssignmentRole, name="assignmentrole", native_enum=True, create_type=False),
        nullable=True
    )
    method = Column(
        SAEnum(AssignmentMethod, name="assignmentmethod", native_enum=True, create_type=False),
        nullable=True
    )
    status = Column(
        SAEnum(AssignmentStatus, name="assignmentstatus", native_enum=True, create_type=False),
        default=AssignmentStatus.pending,
        nullable=True
    )
    
    deadline = Column(DateTime, nullable=True)
    assigned_by = Column(UUID(as_uuid=False), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    __table_args__ = (
        UniqueConstraint('document_id', 'reviewer_id', name='uq_document_reviewer'),
    )

    document = relationship("Document", back_populates="assignments")
    review = relationship("Review", back_populates="assignment", uselist=False)
    form_schema = relationship("FormSchema", back_populates="assignments")
    form_responses = relationship("FormResponse", back_populates="assignment")


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