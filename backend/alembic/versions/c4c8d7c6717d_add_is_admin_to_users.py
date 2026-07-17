"""add is_admin to users

Revision ID: c4c8d7c6717d
Revises: 0a14c69b3420
Create Date: 2026-07-17 13:44:19.507270

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c4c8d7c6717d'
down_revision: Union[str, None] = '0a14c69b3420'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Adiciona a coluna permitindo nulos inicialmente (para não quebrar dados existentes)
    op.add_column('users', sa.Column('is_admin', sa.Boolean(), nullable=True))
    
    # 2. Define que todos os usuários atuais comecem como FALSE (não admins)
    op.execute("UPDATE users SET is_admin = FALSE")
    
    # 3. Altera a coluna para ser NOT NULL e define o padrão como False para futuros registros
    op.alter_column('users', 'is_admin',
               existing_type=sa.Boolean(),
               nullable=False,
               server_default=sa.text('false'))


def downgrade() -> None:
    # Remove a coluna caso precise desfazer a migração
    op.drop_column('users', 'is_admin')
