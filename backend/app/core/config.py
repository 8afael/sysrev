from pydantic_settings import BaseSettings
 
class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql+asyncpg://sysrev_user:sysrev_pass@db:5432/sysrev_db"
    SECRET_KEY: str = "troque-esta-chave-em-producao"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    ENVIRONMENT: str = "development"
 
    class Config:
        env_file = ".env"
 
 
settings = Settings()