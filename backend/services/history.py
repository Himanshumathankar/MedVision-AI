from typing import List
from sqlmodel import select
from app.db import get_session
from models.db import ScanHistory


def add_history(entry: ScanHistory) -> None:
    with get_session() as session:
        session.add(entry)
        session.commit()


def list_history(user_id: str) -> List[ScanHistory]:
    with get_session() as session:
        stmt = select(ScanHistory).where(ScanHistory.user_id == user_id).order_by(ScanHistory.created_at.desc())
        return list(session.exec(stmt).all())
