from fastapi import APIRouter, UploadFile, File
from models.schemas import UploadResponse
from services.storage import upload_bytes_image

router = APIRouter()


@router.post("/image", response_model=UploadResponse)
async def upload_image(file: UploadFile = File(...)) -> UploadResponse:
    content = await file.read()
    result = upload_bytes_image(content)
    return UploadResponse(asset_id=result.get("asset_id"), url=result.get("secure_url"))
