from fastapi import FastAPI
from app.config import get_settings
from app.db import init_db
from app.logging import configure_logging
from routes.predict import router as predict_router
from routes.upload import router as upload_router
from routes.report import router as report_router
from routes.history import router as history_router
from routes.profile import router as profile_router
from routes.auth import router as auth_router


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    app = FastAPI(
        title="MedVision AI",
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.include_router(auth_router, prefix="/auth", tags=["auth"])
    app.include_router(upload_router, prefix="/upload", tags=["uploads"])
    app.include_router(predict_router, prefix="/predict", tags=["predictions"])
    app.include_router(report_router, prefix="/report", tags=["reports"])
    app.include_router(history_router, prefix="/history", tags=["history"])
    app.include_router(profile_router, prefix="/profile", tags=["profile"])

    @app.on_event("startup")
    def _startup() -> None:
        init_db(settings.database_url)

    return app
