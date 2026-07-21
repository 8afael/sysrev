import io
import json
import os
from typing import Tuple, Optional
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseUpload

from dotenv import load_dotenv
load_dotenv(".env")

# Escopo necessário para ler e escrever arquivos criados no Drive
SCOPES = ['https://www.googleapis.com/auth/drive.file']

def _get_drive_service():
    """
    Inicializa o cliente da API do Google Drive usando as credenciais da Service Account.
    Geralmente lido de um arquivo 'credentials.json' ou de uma variável de ambiente GOOGLE_CREDENTIALS_JSON.
    """
    creds_json = os.getenv("GOOGLE_CREDENTIALS_JSON")
    
    if creds_json:
        # Se você armazenou a string JSON diretamente no .env
        creds_info = json.loads(creds_json)
        credentials = Credentials.from_service_account_info(creds_info, scopes=SCOPES)
    elif os.path.exists("credentials.json"):
        # Se você salvou o arquivo credentials.json na raiz do projeto
        credentials = Credentials.from_service_account_file("credentials.json", scopes=SCOPES)
    else:
        raise ValueError("Google Drive credentials not configured properly.")

    return build('drive', 'v3', credentials=credentials)


async def upload_file_to_drive(
    file_obj, 
    filename: str, 
    mime_type: str = "application/pdf", 
    folder_id: Optional[str] = None
) -> Tuple[str, str]:
    """
    Envia um arquivo para o Google Drive.
    Retorna uma tupla (drive_file_id, web_view_link).
    """
    service = _get_drive_service()

    file_metadata = {'name': filename}
    
    # Se você quiser salvar em uma pasta específica compartilhada do Drive
    target_folder = folder_id or os.getenv("GOOGLE_DRIVE_FOLDER_ID")
    if target_folder:
        file_metadata['parents'] = [target_folder]

    media = MediaIoBaseUpload(
        io.BytesIO(file_obj.read()), 
        mimetype=mime_type, 
        resumable=False
    )

    # Executa o upload e solicita de volta o ID e o link de visualização
    uploaded_file = service.files().create(
        body=file_metadata,
        media_body=media,
        fields='id, webViewLink'
    ).execute()

    file_id = uploaded_file.get('id')
    web_view_link = uploaded_file.get('webViewLink')

    # Ajusta as permissões do arquivo enviado para que qualquer pessoa com o link possa visualizar
    service.permissions().create(
        fileId=file_id,
        body={'type': 'anyone', 'role': 'reader'}
    ).execute()

    return file_id, web_view_link


async def delete_file_from_drive(drive_file_id: str) -> bool:
    """
    Exclui permanentemente um arquivo do Google Drive dado o seu ID.
    """
    service = _get_drive_service()
    try:
        service.files().delete(fileId=drive_file_id).execute()
        return True
    except Exception as e:
        print(f"Erro ao deletar arquivo no Google Drive ({drive_file_id}): {e}")
        return False