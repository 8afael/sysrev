import json
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.core.deps import get_current_user, require_role, get_role_in_project
from app.models.models import User, Document, Assignment 
from app.models.enums import (
    ProjectRole, AssignmentRole, AssignmentMethod, 
    AssignmentStatus, SubmissionStatus, DocumentPhase
)
from app.schemas.review_schema import DocumentCreate, DocumentOut
from app.services.audit_service import log_audit
# 🌟 Import correto do serviço S3
from app.services.google_drive_service import upload_file_to_s3

router = APIRouter(prefix="/projects/{project_id}/documents", tags=["documents"])

@router.post("/batch-upload", status_code=status.HTTP_201_CREATED)
async def upload_documents_batch(
    project_id: str,
    files: List[UploadFile] = File(...),
    assignments: str = Form(...),
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    """
    Recebe os arquivos e o JSON de atribuições, envia os PDFs para o S3 
    e grava os registros em 'documents' e 'assignments' dentro do banco de dados.
    """
    try:
        # 1. Desserializa o JSON de atribuições vindo do frontend
        # Esperado: [{"filename": "doc1.pdf", "assigned_members": [{"user_id": "uuid1", "role": "reviewer1"}, ...]}]
        assignments_data = json.loads(assignments) if assignments else []
        assignment_map = {
            item.get("filename"): item.get("assigned_members", [])  # 👈 trocado
            for item in assignments_data
        }

        created_documents = []

        # 2. Processa cada arquivo enviado
        for file in files:
            # Upload físico para a AWS S3
            file_key, s3_url = await upload_file_to_s3(
                file_obj=file.file,
                filename=file.filename,
                mime_type=file.content_type,
                project_id=project_id
            )

            # Instancia o registro do Documento
            doc_id = str(uuid.uuid4())
            new_doc = Document(
                id=doc_id,
                project_id=project_id,
                title=file.filename,
                source_type="PDF_UPLOAD",
                file_url=s3_url,
                drive_file_id=file_key, # Guarda o s3_key aqui
                file_size=file.size,
                submission_status=SubmissionStatus.registered,
                phase=DocumentPhase.identification,
                copyright_status="unknown",
                access_restriction="restricted"
            )
            db.add(new_doc)

            # Instancia as Atribuições de Revisores (Assignments)
            assigned_members = assignment_map.get(file.filename, [])  # 👈 trocado

            for member in assigned_members:  # 👈 trocado (antes: for idx, reviewer_id in enumerate(...))
                reviewer_id = member.get("user_id")
                if not reviewer_id:
                    continue

                raw_role = member.get("role", "reviewer1")
                try:
                    role_to_assign = AssignmentRole(raw_role)  # 👈 usa o papel escolhido no front
                except ValueError:
                    role_to_assign = AssignmentRole.reviewer1  # fallback seguro se vier algo inválido

                new_assignment = Assignment(
                    id=str(uuid.uuid4()),
                    document_id=doc_id,
                    reviewer_id=str(reviewer_id),
                    role=role_to_assign,
                    method=AssignmentMethod.manual,
                    status=AssignmentStatus.pending,
                    assigned_by=user.id
                )
                db.add(new_assignment)

            await log_audit(
                db, 
                user.id, 
                "create_batch", 
                "document", 
                doc_id, 
                data_after={"title": file.filename, "s3_key": file_key}
            )

            created_documents.append({
                "id": doc_id,
                "filename": file.filename,
                "s3_key": file_key,
                "url": s3_url,
                "assigned_users_count": len(assigned_members)  # 👈 trocado
            })

        # 3. Efetiva todas as gravações no banco de dados
        await db.commit()

        return {
            "message": "Files uploaded and saved to database successfully",
            "documents": created_documents
        }

    except Exception as e:
        await db.rollback()
        print(f"❌ Erro na rota batch-upload: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error saving documents to database: {str(e)}"
        )
# @router.post("/batch-upload", status_code=status.HTTP_201_CREATED)
# async def upload_documents_batch(
#     project_id: str,
#     files: List[UploadFile] = File(...),
#     assignments: str = Form(...),
#     user: User = Depends(get_current_user),
#     _role=Depends(require_role(ProjectRole.admin)),
#     db: AsyncSession = Depends(get_db),
# ):
#     """
#     Recebe os arquivos e o JSON de atribuições, envia os PDFs para o S3 
#     e grava os registros em 'documents' e 'assignments' dentro do banco de dados.
#     """
#     try:
#         # 1. Desserializa o JSON de atribuições vindo do frontend
#         # Esperado: [{"filename": "doc1.pdf", "assigned_user_ids": ["uuid1", "uuid2"]}]
#         assignments_data = json.loads(assignments) if assignments else []
#         assignment_map = {
#             item.get("filename"): item.get("assigned_user_ids", [])
#             for item in assignments_data
#         }

#         created_documents = []

#         # 2. Processa cada arquivo enviado
#         for file in files:
#             # Upload físico para a AWS S3
#             file_key, s3_url = await upload_file_to_s3(
#                 file_obj=file.file,
#                 filename=file.filename,
#                 mime_type=file.content_type,
#                 project_id=project_id
#             )

#             # Instancia o registro do Documento
#             doc_id = str(uuid.uuid4())
#             new_doc = Document(
#                 id=doc_id,
#                 project_id=project_id,
#                 title=file.filename,
#                 source_type="PDF_UPLOAD",
#                 file_url=s3_url,
#                 drive_file_id=file_key, # Guarda o s3_key aqui
#                 file_size=file.size,
#                 submission_status=SubmissionStatus.registered,
#                 phase=DocumentPhase.identification,
#                 copyright_status="unknown",
#                 access_restriction="restricted"
#             )
#             db.add(new_doc)

#             # Instancia as Atribuições de Revisores (Assignments)
#             assigned_user_ids = assignment_map.get(file.filename, [])
#             for idx, reviewer_id in enumerate(assigned_user_ids):
#                 role_to_assign = AssignmentRole.reviewer1 if idx == 0 else AssignmentRole.reviewer2

#                 new_assignment = Assignment(
#                     id=str(uuid.uuid4()),
#                     document_id=doc_id,
#                     reviewer_id=str(reviewer_id),
#                     role=role_to_assign, # <-- Atribui explicitamente AssignmentRole.reviewer1 / reviewer2
#                     method=AssignmentMethod.manual,
#                     status=AssignmentStatus.pending,
#                     assigned_by=user.id
#                 )
#                 db.add(new_assignment)

#             await log_audit(
#                 db, 
#                 user.id, 
#                 "create_batch", 
#                 "document", 
#                 doc_id, 
#                 data_after={"title": file.filename, "s3_key": file_key}
#             )

#             created_documents.append({
#                 "id": doc_id,
#                 "filename": file.filename,
#                 "s3_key": file_key,
#                 "url": s3_url,
#                 "assigned_users_count": len(assigned_user_ids)
#             })

#         # 3. Efetiva todas as gravações no banco de dados
#         await db.commit()

#         return {
#             "message": "Files uploaded and saved to database successfully",
#             "documents": created_documents
#         }

#     except Exception as e:
#         # Em caso de qualquer erro no meio do processo, desfaz no banco
#         await db.rollback()
#         print(f"❌ Erro na rota batch-upload: {str(e)}")
#         raise HTTPException(
#             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#             detail=f"Error saving documents to database: {str(e)}"
#         )


@router.post("", response_model=DocumentOut, status_code=201)
async def register_document(
    project_id: str,
    payload: DocumentCreate,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    doc = Document(project_id=project_id, **payload.model_dump())
    db.add(doc)
    await log_audit(db, user.id, "create", "document", None, data_after={"title": payload.title})
    await db.commit()
    await db.refresh(doc)
    return doc


@router.get("", response_model=List[DocumentOut])
async def list_documents(
    project_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    role = await get_role_in_project(project_id, user, db)
    if role is None:
        raise HTTPException(status_code=403, detail="No access to this project")

    stmt = (
        select(Document)
        .options(
            selectinload(Document.assignments).selectinload(Assignment.review)
        )
        .where(Document.project_id == project_id)
        .order_by(Document.created_at.desc())
    )

    result = await db.execute(stmt)
    return result.scalars().all()


@router.delete("/{document_id}", status_code=204)
async def delete_document(
    project_id: str,
    document_id: str,
    user: User = Depends(get_current_user),
    _role=Depends(require_role(ProjectRole.admin)),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Document).where(Document.id == document_id))
    doc = result.scalar_one_or_none()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    await log_audit(db, user.id, "delete", "document", document_id)
    await db.delete(doc)
    await db.commit()