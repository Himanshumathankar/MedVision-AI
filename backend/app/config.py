from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_env: str = "dev"
    log_level: str = "INFO"

    jwt_secret: str = "change-me"
    jwt_issuer: str = "medvision-ai"
    jwt_audience: str = "medvision-ai-clients"
    jwt_exp_minutes: int = 60

    database_url: str = "postgresql+psycopg2://medvision:medvision@localhost:5432/medvision"
    redis_url: str = "redis://localhost:6379/0"

    cloudinary_cloud_name: str = ""
    cloudinary_api_key: str = ""
    cloudinary_api_secret: str = ""

    firebase_project_id: str = ""
    firebase_credentials_path: str = ""

    artifacts_dir: str = "./artifacts"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
