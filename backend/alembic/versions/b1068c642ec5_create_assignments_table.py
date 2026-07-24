"""create_assignments_table

Revision ID: b1068c642ec5
Revises: 5fe073fc0333
Create Date: 2026-07-22 10:53:35.070455

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = 'b1068c642ec5'
down_revision: Union[str, None] = '5fe073fc0333'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade() -> None:
    # 1. Garante a criação dos ENUMs caso não existam (usando bloco nativo do PG)
    op.execute("""
        DO $$ BEGIN
            CREATE TYPE assignmentrole AS ENUM ('reviewer', 'lead');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    op.execute("""
        DO $$ BEGIN
            CREATE TYPE assignmentmethod AS ENUM ('manual', 'automatic');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    op.execute("""
        DO $$ BEGIN
            CREATE TYPE assignmentstatus AS ENUM ('pending', 'in_progress', 'completed', 'rejected');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
    """)

    # 2. Cria a Tabela referenciando os nomes dos ENUMs nativos diretamente do Postgres
    op.create_table(
        'assignments',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('document_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('reviewer_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('form_schema_id', postgresql.UUID(as_uuid=True), nullable=True),
        
        # Usamos postgresql.ENUM especificando create_type=False
        sa.Column('role', postgresql.ENUM('reviewer', 'lead', name='assignmentrole', create_type=False), nullable=True),
        sa.Column('method', postgresql.ENUM('manual', 'automatic', name='assignmentmethod', create_type=False), nullable=True),
        sa.Column('status', postgresql.ENUM('pending', 'in_progress', 'completed', 'rejected', name='assignmentstatus', create_type=False), server_default='pending', nullable=True),
        
        sa.Column('deadline', sa.DateTime(), nullable=True),
        sa.Column('assigned_by', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('NOW()'), nullable=True),
        
        sa.PrimaryKeyConstraint('id', name='assignments_pkey'),
        sa.ForeignKeyConstraint(['document_id'], ['documents.id'], name='fk_assignments_document', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['reviewer_id'], ['users.id'], name='fk_assignments_reviewer', ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['assigned_by'], ['users.id'], name='fk_assignments_assigned_by', ondelete='SET NULL'),
        sa.UniqueConstraint('document_id', 'reviewer_id', name='uq_document_reviewer')
    )

    op.create_index('idx_assignments_document_id', 'assignments', ['document_id'])
    op.create_index('idx_assignments_reviewer_id', 'assignments', ['reviewer_id'])


def downgrade() -> None:
    op.drop_index('idx_assignments_reviewer_id', table_name='assignments')
    op.drop_index('idx_assignments_document_id', table_name='assignments')
    op.drop_table('assignments')
