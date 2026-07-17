from typing import Optional, Any
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.models import AuditLog

async def log_audit(
    db: AsyncSession,
    user_id: Optional[str],
    action: str,
    entity: str,
    entity_id: Optional[str] = None,
    data_before: Optional[dict[str, Any]] = None,
    data_after: Optional[dict[str, Any]] = None,
):
    log = AuditLog(
        user_id=user_id,
        action=action,
        entity=entity,
        entity_id=entity_id,
        data_before=data_before,
        data_after=data_after,
    )
    db.add(log)
    # commit is the caller's responsibility, to group within the same transaction