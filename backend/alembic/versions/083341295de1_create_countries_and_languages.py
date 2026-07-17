"""create_countries_and_languages

Revision ID: 083341295de1
Revises: df87335bf5d8
Create Date: 2026-07-15 19:51:42.009388

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '083341295de1'
down_revision: Union[str, None] = 'df87335bf5d8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Criação da Tabela de Países
    op.create_table('countries',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=100), nullable=False),
    sa.Column('code', sa.String(length=3), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.create_index(op.f('ix_countries_id'), 'countries', ['id'], unique=False)

    # 2. Criação da Tabela de Idiomas
    op.create_table('languages',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=100), nullable=False),
    sa.Column('code', sa.String(length=5), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('name')
    )
    op.create_index(op.f('ix_languages_id'), 'languages', ['id'], unique=False)

    # 3. Tabela de Associação: project_countries (CORRIGIDA COM sa.UUID())
    op.create_table('project_countries',
    sa.Column('project_id', sa.UUID(), nullable=False),  # Alterado de Integer para UUID
    sa.Column('country_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['country_id'], ['countries.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['project_id'], ['projects.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('project_id', 'country_id')
    )

    # 4. Tabela de Associação: project_languages (CORRIGIDA COM sa.UUID())
    op.create_table('project_languages',
    sa.Column('project_id', sa.UUID(), nullable=False),  # Alterado de Integer para UUID
    sa.Column('language_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['language_id'], ['languages.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['project_id'], ['projects.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('project_id', 'language_id')
    )

    # 5. Remove as colunas de texto simples antigas do projeto se elas existirem
    # Usamos try/except ou verificações simples para evitar erros caso elas já tenham sido removidas
    try:
        op.drop_column('projects', 'languages')
        op.drop_column('projects', 'countries')
    except Exception:
        pass


def downgrade() -> None:
    # Remove as tabelas criadas no upgrade
    op.drop_table('project_languages')
    op.drop_table('project_countries')
    op.drop_index(op.f('ix_languages_id'), table_name='languages')
    op.drop_table('languages')
    op.drop_index(op.f('ix_countries_id'), table_name='countries')
    
    # Restaura as colunas antigas em projects caso queira voltar atrás
    op.add_column('projects', sa.Column('countries', postgresql.ARRAY(sa.VARCHAR()), autoincrement=False, nullable=True))
    op.add_column('projects', sa.Column('languages', postgresql.ARRAY(sa.VARCHAR()), autoincrement=False, nullable=True))
    # ### end Alembic commands ###
