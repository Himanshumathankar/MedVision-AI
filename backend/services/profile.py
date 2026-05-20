from typing import Optional
from sqlmodel import select
from app.db import get_session
from models.db import UserProfile


def get_profile(user_id: str) -> Optional[UserProfile]:
    with get_session() as session:
        stmt = select(UserProfile).where(UserProfile.user_id == user_id)
        return session.exec(stmt).first()


def upsert_profile(profile: UserProfile) -> UserProfile:
    with get_session() as session:
        existing = session.get(UserProfile, profile.user_id)
        if existing:
            existing.display_name = profile.display_name
            existing.email = profile.email
            existing.theme = profile.theme
            session.add(existing)
            session.commit()
            session.refresh(existing)
            return existing
        session.add(profile)
        session.commit()
        session.refresh(profile)
        return profile
