"""create_project_work_groups_association

Revision ID: 0a14c69b3420
Revises: 46a37e2b3df0
Create Date: 2026-07-16 14:39:57.686057

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0a14c69b3420'
down_revision: Union[str, None] = '46a37e2b3df0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Como as tabelas e chaves estrangeiras já existem fisicamente no banco,
    # apenas registramos esta versão no histórico do Alembic.
    pass


def downgrade() -> None:
    pass