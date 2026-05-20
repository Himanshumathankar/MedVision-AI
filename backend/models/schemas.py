from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class UploadResponse(BaseModel):
    asset_id: str
    url: str


class PredictionRequest(BaseModel):
    image_url: Optional[str] = None
    image_base64: Optional[str] = None


class PredictionResult(BaseModel):
    label: str
    confidence: float
    probability: float
    risk_level: str
    processing_time_ms: int
    gradcam_url: Optional[str] = None
    shap_values: Optional[List[float]] = None


class ReportRequest(BaseModel):
    prediction: PredictionResult
    patient_id: Optional[str] = None
    patient_name: Optional[str] = None
    scan_date: Optional[datetime] = None
    notes: Optional[str] = None


class ReportResponse(BaseModel):
    report_url: str


class HistoryItem(BaseModel):
    id: str
    created_at: datetime
    label: str
    confidence: float
    image_url: Optional[str] = None


class HistoryResponse(BaseModel):
    items: List[HistoryItem]


class ProfileResponse(BaseModel):
    user_id: str
    display_name: Optional[str] = None
    email: Optional[str] = None
    theme: str = "system"


class TokenExchangeRequest(BaseModel):
    firebase_token: str


class TokenExchangeResponse(BaseModel):
    access_token: str
    token_type: str = Field(default="bearer")
    expires_in: int
