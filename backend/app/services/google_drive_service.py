import os
import uuid
import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import HTTPException, status
from typing import Tuple, BinaryIO

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
AWS_BUCKET_NAME = os.getenv("AWS_S3_BUCKET_NAME", "bucketreviewhub")

s3_client = boto3.client(
    "s3",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    region_name=AWS_REGION
)

async def upload_file_to_s3(
    file_obj: BinaryIO,
    filename: str,
    mime_type: str = "application/pdf",
    project_id: str = "general"
) -> Tuple[str, str]:
    """
    Realiza o upload seguro para o S3 e retorna uma Presigned URL pronta para exibição.
    """
    unique_file_id = str(uuid.uuid4())
    s3_key = f"projects/{project_id}/{unique_file_id}_{filename}"

    try:
        if hasattr(file_obj, "seek"):
            file_obj.seek(0)

        # 1. Envia o arquivo para o S3
        s3_client.upload_fileobj(
            file_obj,
            AWS_BUCKET_NAME,
            s3_key,
            ExtraArgs={"ContentType": mime_type}
        )

        # 2. Gera a URL temporária com acesso direto para exibição do PDF (Válida por 7 dias)
        url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': AWS_BUCKET_NAME, 'Key': s3_key},
            ExpiresIn=604800
        )

        return s3_key, url

    except (BotoCoreError, ClientError) as e:
        print(f"❌ Erro S3: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error uploading file to AWS S3: {str(e)}"
        )

async def delete_file_from_s3(s3_key: str) -> None:
    """
    Remove um arquivo do bucket S3 a partir da sua key.
    Não lança erro se o arquivo já não existir (idempotente) —
    apenas loga e propaga falhas reais de credencial/permissão/rede.
    """
    if not s3_key:
        return

    try:
        s3_client.delete_object(
            Bucket=AWS_BUCKET_NAME,
            Key=s3_key
        )
    except (BotoCoreError, ClientError) as e:
        print(f"❌ Erro ao excluir arquivo do S3 ({s3_key}): {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error deleting file from AWS S3: {str(e)}"
        )