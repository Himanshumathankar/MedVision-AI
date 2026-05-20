import time
from fastapi import APIRouter, Depends, HTTPException
from models.schemas import PredictionRequest, PredictionResult
from app.deps import get_current_user
from services.inference import InferenceService
from services.history import add_history
from models.db import ScanHistory

router = APIRouter()


@router.post("/breast-cancer", response_model=PredictionResult)
def predict_breast_cancer(payload: PredictionRequest, user=Depends(get_current_user)) -> PredictionResult:
    started = time.time()
    service = InferenceService()
    result = service.predict(payload)
    if not result:
        raise HTTPException(status_code=400, detail="Prediction failed")

    add_history(
        ScanHistory(
            user_id=user.get("sub"),
            label=result.label,
            confidence=result.confidence,
            image_url=payload.image_url,
            gradcam_url=result.gradcam_url,
        )
    )
    elapsed = int((time.time() - started) * 1000)
    result.processing_time_ms = elapsed
    return result
