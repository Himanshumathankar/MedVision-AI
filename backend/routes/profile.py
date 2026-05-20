from fastapi import APIRouter, Depends
from app.deps import get_current_user
from models.schemas import ProfileResponse
from services.profile import get_profile

router = APIRouter()


@router.get("/", response_model=ProfileResponse)
def profile(user=Depends(get_current_user)) -> ProfileResponse:
    profile = get_profile(user.get("sub"))
    if profile:
        return ProfileResponse(
            user_id=profile.user_id,
            display_name=profile.display_name,
            email=profile.email,
            theme=profile.theme,
        )
    return ProfileResponse(user_id=user.get("sub"), email=user.get("email"))
