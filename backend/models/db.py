from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field


class ScanHistory(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    label: str
    confidence: float
    image_url: Optional[str] = None
    gradcam_url: Optional[str] = None


class UserProfile(SQLModel, table=True):
    user_id: str = Field(primary_key=True)
    display_name: Optional[str] = None
    email: Optional[str] = None
    theme: str = "system"
