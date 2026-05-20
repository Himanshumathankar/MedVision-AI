from fastapi import APIRouter, Depends
from models.schemas import ReportRequest, ReportResponse
from app.deps import get_current_user
from services.report import build_report_pdf
from services.storage import upload_bytes_image

router = APIRouter()


@router.post("/generate", response_model=ReportResponse)
def generate_report(payload: ReportRequest, user=Depends(get_current_user)) -> ReportResponse:
    pdf_bytes = build_report_pdf(payload)
    result = upload_bytes_image(pdf_bytes, suffix=".pdf", resource_type="raw")
    return ReportResponse(report_url=result.get("secure_url"))
