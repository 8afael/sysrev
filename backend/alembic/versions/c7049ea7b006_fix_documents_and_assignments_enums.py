"""fix_documents_and_assignments_enums

Revision ID: c7049ea7b006
Revises: b1068c642ec5
Create Date: 2026-07-22 22:13:43.288788

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'c7049ea7b006'
down_revision: Union[str, None] = 'b1068c642ec5'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Garante a criação dos ENUMs nativos do PostgreSQL
    submission_status_enum = postgresql.ENUM('registered', 'pending', 'submitted', name='submissionstatus', create_type=False)
    submission_status_enum.create(op.get_bind(), checkfirst=True)

    document_phase_enum = postgresql.ENUM('identification', 'screening', 'eligibility', 'included', name='documentphase', create_type=False)
    document_phase_enum.create(op.get_bind(), checkfirst=True)

    assignment_role_enum = postgresql.ENUM('reviewer', 'arbiter', name='assignmentrole', create_type=False)
    assignment_role_enum.create(op.get_bind(), checkfirst=True)

    assignment_method_enum = postgresql.ENUM('manual', 'automatic', name='assignmentmethod', create_type=False)
    assignment_method_enum.create(op.get_bind(), checkfirst=True)

    assignment_status_enum = postgresql.ENUM('pending', 'in_progress', 'completed', name='assignmentstatus', create_type=False)
    assignment_status_enum.create(op.get_bind(), checkfirst=True)

    # 2. Recriação da tabela DOCUMENTS (Usando postgresql.UUID para bater com a tabela projects)
    op.create_table(
        'documents',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('project_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('title', sa.String(length=500), nullable=False),
        sa.Column('source_type', sa.String(length=100), nullable=True),
        sa.Column('file_url', sa.String(length=1000), nullable=True),
        sa.Column('external_reference', sa.String(length=1000), nullable=True),
        sa.Column('copyright_status', sa.String(length=50), server_default='unknown', nullable=True),
        sa.Column('access_restriction', sa.String(length=50), server_default='restricted', nullable=True),
        sa.Column('language', sa.String(length=10), nullable=True),
        sa.Column('country_region', sa.String(length=100), nullable=True),
        sa.Column('submission_status', submission_status_enum, nullable=True),
        sa.Column('duplicate_flag', sa.Boolean(), server_default='false', nullable=True),
        sa.Column('phase', document_phase_enum, nullable=True),
        sa.Column('extra_metadata', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('drive_file_id', sa.String(length=255), nullable=True),
        sa.Column('file_size', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['project_id'], ['projects.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    
    op.create_index('ix_documents_drive_file_id', 'documents', ['drive_file_id'], unique=False)

    # 3. Recriação da tabela ASSIGNMENTS (Usando postgresql.UUID)
    op.create_table(
        'assignments',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('document_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('reviewer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('form_schema_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('role', assignment_role_enum, nullable=True),
        sa.Column('method', assignment_method_enum, nullable=True),
        sa.Column('status', assignment_status_enum, nullable=True),
        sa.Column('deadline', sa.DateTime(), nullable=True),
        sa.Column('assigned_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['assigned_by'], ['users.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['document_id'], ['documents.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['form_schema_id'], ['form_schemas.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['reviewer_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('document_id', 'reviewer_id', name='uq_document_reviewer')
    )

    op.create_index('idx_assignments_document_id', 'assignments', ['document_id'], unique=False)
    op.create_index('idx_assignments_reviewer_id', 'assignments', ['reviewer_id'], unique=False)

    # 4. Ajustes extras em tabelas paralelas
    op.alter_column('project_work_groups', 'associated_at',
               existing_type=postgresql.TIMESTAMP(timezone=True),
               type_=sa.DateTime(),
               nullable=True,
               existing_server_default=sa.text('now()'))
    
    op.alter_column('users', 'password_hash',
               existing_type=sa.VARCHAR(length=255),
               nullable=False)


def downgrade() -> None:
    op.drop_table('assignments')
    op.drop_table('documents')