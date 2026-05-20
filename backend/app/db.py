from typing import Optional
from sqlmodel import SQLModel, Session, create_engine

_engine = None


def init_db(database_url: str) -> None:
    global _engine
    if _engine is None:
        _engine = create_engine(database_url, pool_pre_ping=True)
        SQLModel.metadata.create_all(_engine)


def get_session() -> Session:
    if _engine is None:
        raise RuntimeError("Database engine is not initialized")
    return Session(_engine)
