import os
import subprocess
from datetime import datetime

# ==============================================================================
# CONFIGURAÇÕES DO BANCO DE DADOS (Ajuste os valores conforme seu ambiente)
# ==============================================================================
CONTAINER_NAME_LOCAL = "sysrev_db"
CONTAINER_NAME_SERVER = "db"
DB_USER = "sysrev_user"        # Seu usuário do Postgres
DB_NAME = "sysrev_db" # Substitua pelo nome real do seu banco de dados
DB_PASSWORD = "sysrev_pass"  # Substitua pela senha real do banco

# Diretório onde os backups serão salvos/procurados (pasta atual do script)
BACKUP_DIR = os.path.dirname(os.path.abspath(__file__))

# ==============================================================================
# MÉTODO 1: FAZER BACKUP
# ==============================================================================
def fazer_backup():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nome_arquivo = f"sysrev_db_{timestamp}.sql"
    caminho_final = os.path.join(BACKUP_DIR, nome_arquivo)
    
    print(f"🔄 Iniciando backup da estrutura e dados do container '{CONTAINER_NAME_LOCAL}'...")
    
    # Comando para rodar o pg_dump direto de dentro do Container Docker
    # O '--clean' é ótimo porque adiciona comandos 'DROP TABLE' antes dos 'CREATE' no SQL,
    # facilitando restaurações futuras sobre bancos que já possuem dados antigos.
    comando = [
        "docker", "exec", "-i", CONTAINER_NAME_LOCAL,
        "pg_dump",
        "-U", DB_USER,
        "-d", DB_NAME,
        "-F", "p",  # Formato Texto Puro (.sql)
        "--clean",  # Limpa objetos antes de recriá-los
    ]
    
    # Injeta a senha no ambiente do processo para o pg_dump não solicitar interativamente
    env_modificado = os.environ.copy()
    env_modificado["PGPASSWORD"] = DB_PASSWORD
    
    try:
        # Executa o comando e joga a saída direto para o arquivo físico na sua máquina hospedeira
        with open(caminho_final, "w", encoding="utf-8") as arquivo_sql:
            resultado = subprocess.run(
                comando,
                env=env_modificado,
                stdout=arquivo_sql,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            
        print(f"✅ Backup concluído com sucesso!")
        print(f"📂 Arquivo gerado: {caminho_final}")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao executar o pg_dump dentro do Docker: {e.stderr}")
        # Remove o arquivo vazio que possa ter sido criado pelo context manager
        if os.path.exists(caminho_final):
            os.remove(caminho_final)
    except Exception as e:
        print(f"❌ Ocorreu um erro inesperado: {str(e)}")

# ==============================================================================
# MÉTODO 2: RESTAURAR BACKUP
# ==============================================================================
def restaurar_backup():
    print("🔍 Procurando por arquivos de backup (.sql) no diretório...")
    
    arquivos_backup = [
        f for f in os.listdir(BACKUP_DIR) 
        if f.startswith("sysrev_db_") and f.endswith(".sql")
    ]
    
    # Se não existir nenhum arquivo, encerra o script graciosamente
    if not arquivos_backup:
        print("⚠️ Nenhum arquivo de backup '.sql' foi encontrado no diretório.")
        print("🛑 Encerrando o script.")
        return

    # Ordena os arquivos para encontrar o mais recente (com base no timestamp do nome)
    arquivos_backup.sort(reverse=True)
    arquivo_para_restaurar = arquivos_backup[0]
    caminho_completo = os.path.join(BACKUP_DIR, arquivo_para_restaurar)
    
    print(f"📋 Encontrado o backup mais recente: '{arquivo_para_restaurar}'")
    confirmacao = input(f"❓ Deseja restaurar este arquivo agora no container '{CONTAINER_NAME_SERVER}'? (s/n): ")
    
    if confirmacao.lower() != 's':
        print("🛑 Operação cancelada pelo usuário. Encerrando.")
        return

    print(f"🔄 Executando restauração estrutural e de dados. Aguarde...")
    
    # Comando psql para ler a entrada SQL que vamos injetar
    comando = [
        "docker", "exec", "-i", CONTAINER_NAME_SERVER,
        "psql",
        "-U", DB_USER,
        "-d", DB_NAME
    ]
    
    env_modificado = os.environ.copy()
    env_modificado["PGPASSWORD"] = DB_PASSWORD
    
    try:
        # Abre o arquivo local e injeta os comandos diretamente na entrada padrão (stdin) do Docker
        with open(caminho_completo, "r", encoding="utf-8") as arquivo_sql:
            resultado = subprocess.run(
                comando,
                env=env_modificado,
                stdin=arquivo_sql,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )
            
        print(f"🎉 Sucesso! Banco de dados restaurado para o estado de: {arquivo_para_restaurar}")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro crítico na restauração via psql:\n{e.stderr}")
    except Exception as e:
        print(f"❌ Erro inesperado ao ler arquivo de restauração: {str(e)}")

# ==============================================================================
# EXECUÇÃO DO MENU SCRIPT
# ==============================================================================
if __name__ == "__main__":
    print("--- Gerador BACKUP POSTGRES ---")
    print("1 - Gerar Novo Backup (Estrutura + Dados)")
    print("2 - Restaurar Backup Mais Recente")
    
    opcao = input("Escolha uma opção (1 ou 2): ")
    print("-" * 42)
    
    if opcao == "1":
        fazer_backup()
    elif opcao == "2":
        restaurar_backup()
    else:
        print("Opção inválida. Encerrando script.")
