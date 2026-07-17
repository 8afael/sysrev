import csv
import re
import uuid
import psycopg2

# 1. Configurações de conexão com o seu Postgres no Docker
# Ajuste as credenciais conforme as configurações do seu container
DB_CONFIG = {
    "dbname": "sysrev_db",
    "user": "sysrev_user",
    "password": "sysrev_pass",
    "host": "localhost",
    "port": "5432"  # Porta mapeada no Docker
}

CSV_FILE_PATH = "/Users/rafa/Downloads/members.csv"  # Caminho do seu arquivo CSV local

# 2. Expressão Regular para remover títulos no início do nome
# Remove "Prof", "Dr", "Ms", "Mrs", "Mr" seguidos ou não de ponto e espaços
TITLES_RE = re.compile(r'^(Prof\.?|Dr\.?|Ms\.?|Mrs\.?|Mr\.?)\s+', re.IGNORECASE)

def clean_name(name: str) -> str:
    """Remove títulos acadêmicos do início do nome."""
    return TITLES_RE.sub('', name).strip()

def import_users():
    try:
        # Conecta ao banco de dados
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Conectado ao banco de dados. Iniciando importação...")

        with open(CSV_FILE_PATH, mode="r", encoding="utf-8") as file:
            # O seu CSV tem duas vírgulas seguidas (coluna vazia):
            # Ex: Prof Eralda GJIKA,,Albania,Universiteti...
            # Mapeamos as colunas ignorando o campo vazio.
            reader = csv.reader(file)
            
            inserted_count = 0
            
            for row in reader:
                if not row or len(row) < 5:
                    continue
                
                raw_name = row[0]
                country = row[2]
                institution = row[3]
                email = row[4].strip().lower() # Normaliza o e-mail para minúsculas
                
                # Limpa o nome (ex: "Prof Eralda GJIKA" -> "Eralda GJIKA")
                cleaned_name = clean_name(raw_name)
                
                # Gera um UUID novo para o id do usuário
                user_id = str(uuid.uuid4())
                
                # Evita duplicados verificando se o e-mail já existe no banco
                cursor.execute("SELECT id FROM public.users WHERE email = %s", (email,))
                if cursor.fetchone():
                    print(f"E-mail {email} já cadastrado. Pulando...")
                    continue
                
                # Insere o usuário com password_hash como NULL
                cursor.execute(
                    """
                    INSERT INTO public.users (id, name, email, country, institution, password_hash, active, created_at)
                    VALUES (%s, %s, %s, %s, %s, NULL, TRUE, NOW())
                    """,
                    (user_id, cleaned_name, email, country, institution)
                )
                inserted_count += 1
                print(f"Pronto para inserir: {cleaned_name} ({email})")
                
            # Salva as alterações no banco de dados
            conn.commit()
            print(f"\nSucesso! {inserted_count} usuários foram importados e limpos.")

    except Exception as e:
        print(f"Erro durante a importação: {e}")
        if 'conn' in locals():
            conn.rollback()
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    import_users()