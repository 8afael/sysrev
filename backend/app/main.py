import os

from fastapi import APIRouter, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.core.config import settings
from app.routers import (
    auth_router,
    user_router,
    assignments_router,
    dashboard_router,
    conflicts_router,
    docs_router,
    forms_router,
    project_router,
    reviews_router,
    work_group_router,
    metadata_router,
)
from app.models import models

app = FastAPI(
    title="ReviewHub",
    description="Collaborative evidence synthesis workflow",
    version="0.1.0-mvp",
    docs_url="/sysrev/api/docs",
    redoc_url="/sysrev/api/redoc",
    openapi_url="/sysrev/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.ENVIRONMENT == "development" else [],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    
)

api = APIRouter(prefix="/sysrev/api")

api.include_router(auth_router.router)
api.include_router(project_router.router)
api.include_router(forms_router.router)
api.include_router(docs_router.router)
api.include_router(assignments_router.router)
api.include_router(reviews_router.router)
api.include_router(conflicts_router.router)
api.include_router(dashboard_router.router)
api.include_router(user_router.router)
api.include_router(work_group_router.router)
api.include_router(metadata_router.router)

app.include_router(api)


# @app.on_event("startup")
# async def on_startup():
#     async with engine.begin() as conn:
#         await conn.run_sync(Base.metadata.create_all)


@app.get("/sysrev/health")
async def health():
    return {"status": "ok", "environment": settings.ENVIRONMENT}