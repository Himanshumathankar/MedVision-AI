from fastapi import APIRouter, HTTPException
from models.schemas import TokenExchangeRequest, TokenExchangeResponse
from services.auth import exchange_firebase_token
from app.config import get_settings

router = APIRouter()


@router.post("/exchange", response_model=TokenExchangeResponse)
def exchange_token(payload: TokenExchangeRequest) -> TokenExchangeResponse:
    settings = get_settings()
    token = exchange_firebase_token(payload.firebase_token)
    if not token:
        raise HTTPException(status_code=401, detail="Invalid Firebase token")
    return TokenExchangeResponse(access_token=token, expires_in=settings.jwt_exp_minutes * 60)
