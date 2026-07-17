"""add work_groups and work_group_members

Revision ID: a1b2c3d4e5f6
Revises: a4e6bb728585
Create Date: 2025-01-15 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "a1b2c3d4e5f6"
down_revision: Union[str, None] = "a4e6bb728585"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ---------- work_groups ----------
    op.create_table(
        "work_groups",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column(
            "project_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("projects.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "created_by",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("NOW()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("NOW()"),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            server_default=sa.text("TRUE"),
            nullable=False,
        ),
    )
    op.create_index(
        "idx_work_groups_project",
        "work_groups",
        ["project_id"],
    )

    # ---------- work_group_members ----------
    op.create_table(
        "work_group_members",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column(
            "work_group_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("work_groups.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "project_user_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("project_users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("role", sa.String(length=50), nullable=True),
        sa.Column(
            "added_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("NOW()"),
            nullable=False,
        ),
        sa.Column(
            "added_by",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.UniqueConstraint(
            "work_group_id",
            "project_user_id",
            name="uq_group_member",
        ),
    )
    op.create_index(
        "idx_wgm_group",
        "work_group_members",
        ["work_group_id"],
    )
    op.create_index(
        "idx_wgm_project_user",
        "work_group_members",
        ["project_user_id"],
    )

    # ---------- trigger para updated_at ----------
    op.execute(
        """
        CREATE OR REPLACE FUNCTION set_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        """
    )
    op.execute(
        """
        CREATE TRIGGER trg_work_groups_updated_at
        BEFORE UPDATE ON work_groups
        FOR EACH ROW
        EXECUTE FUNCTION set_updated_at();
        """
    )


def downgrade() -> None:
    op.execute("DROP TRIGGER IF EXISTS trg_work_groups_updated_at ON work_groups;")
    # Não removemos a função set_updated_at pois outras tabelas podem usá-la.
    # Se tiver certeza que só esta tabela usa, descomente:
    # op.execute("DROP FUNCTION IF EXISTS set_updated_at();")

    op.drop_index("idx_wgm_project_user", table_name="work_group_members")
    op.drop_index("idx_wgm_group", table_name="work_group_members")
    op.drop_table("work_group_members")

    op.drop_index("idx_work_groups_project", table_name="work_groups")
    op.drop_table("work_groups")