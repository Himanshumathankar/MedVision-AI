from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from models.schemas import ReportRequest


def build_report_pdf(payload: ReportRequest) -> bytes:
    buffer = BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    c.setFont("Helvetica-Bold", 16)
    c.drawString(1 * inch, height - 1 * inch, "MedVision AI Diagnostic Report")

    c.setFont("Helvetica", 11)
    y = height - 1.5 * inch
    c.drawString(1 * inch, y, f"Patient: {payload.patient_name or 'N/A'}")
    y -= 0.25 * inch
    c.drawString(1 * inch, y, f"Patient ID: {payload.patient_id or 'N/A'}")
    y -= 0.25 * inch
    scan_date = payload.scan_date.isoformat() if payload.scan_date else "N/A"
    c.drawString(1 * inch, y, f"Scan date: {scan_date}")

    y -= 0.5 * inch
    c.setFont("Helvetica-Bold", 12)
    c.drawString(1 * inch, y, "Prediction")

    y -= 0.25 * inch
    c.setFont("Helvetica", 11)
    c.drawString(1 * inch, y, f"Label: {payload.prediction.label}")
    y -= 0.25 * inch
    c.drawString(1 * inch, y, f"Confidence: {payload.prediction.confidence:.2f}")
    y -= 0.25 * inch
    c.drawString(1 * inch, y, f"Risk level: {payload.prediction.risk_level}")

    y -= 0.5 * inch
    c.setFont("Helvetica-Bold", 12)
    c.drawString(1 * inch, y, "Notes")
    y -= 0.25 * inch
    c.setFont("Helvetica", 11)
    c.drawString(1 * inch, y, payload.notes or "None")

    y -= 0.75 * inch
    c.setFont("Helvetica-Oblique", 9)
    c.drawString(1 * inch, y, "Disclaimer: This report is for clinical assistance only.")

    c.showPage()
    c.save()
    buffer.seek(0)
    return buffer.read()
