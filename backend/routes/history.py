from fastapi import APIRouter, Depends
from app.deps import get_current_user
from models.schemas import HistoryResponse, HistoryItem
from services.history import list_history

router = APIRouter()


@router.get("/", response_model=HistoryResponse)
def history(user=Depends(get_current_user)) -> HistoryResponse:
    items = list_history(user.get("sub"))
    response_items = [
        HistoryItem(
            id=str(entry.id),
            created_at=entry.created_at,
            label=entry.label,
            confidence=entry.confidence,
            image_url=entry.image_url,
        )
        for entry in items
    ]
    return HistoryResponse(items=response_items)
