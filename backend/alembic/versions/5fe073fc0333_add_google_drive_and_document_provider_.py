"""add_google_drive_and_document_provider_fields

Revision ID: 5fe073fc0333
Revises: c4c8d7c6717d
Create Date: 2026-07-21 14:29:06.993621

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '5fe073fc0333'
down_revision: Union[str, None] = 'c4c8d7c6717d'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Novas colunas na tabela 'projects' (Tela 3)
    op.add_column('projects', sa.Column('document_provider', sa.String(length=20), server_default='admin', nullable=True))
    op.add_column('projects', sa.Column('member_instructions', sa.Text(), nullable=True))

    # 2. Novas colunas na tabela 'documents' (Integração Google Drive & Limite de 5MB)
    op.add_column('documents', sa.Column('drive_file_id', sa.String(length=255), nullable=True))
    op.add_column('documents', sa.Column('file_size', sa.Integer(), nullable=True))

    # 3. Índice para otimizar consultas pelo file_id do Drive
    op.create_index(op.f('ix_documents_drive_file_id'), 'documents', ['drive_file_id'], unique=False)


def downgrade() -> None:
    # Reversão caso precise rodar alembic downgrade -1
    op.drop_index(op.f('ix_documents_drive_file_id'), table_name='documents')
    op.drop_column('documents', 'file_size')
    op.drop_column('documents', 'drive_file_id')
    op.drop_column('projects', 'member_instructions')
    op.drop_column('projects', 'document_provider')