
#!/bin/bash

# Função para exibir o manual
show_manual() {
    echo "========================================"
    echo "              Manual de Uso             "
    echo "========================================"
    echo "Este script foi adaptado para gerenciar um servidor SSH."
    echo "Compatível com VPS Contabo."
    echo "Comandos disponíveis:"
    echo " - Instalação de pacotes"
    echo " - Criação de usuários SSH"
    echo " - Gerenciamento básico de contas"
    echo " - Configuração de túnel SSH"
    echo ""
    echo "Certifique-se de estar logado como root e que seu servidor"
    echo "atenda aos requisitos de sistema para a execução correta."
    echo "========================================"
    exit 0
}

# Verifica se o usuário passou --help
if [[ "$1" == "--help" ]]; then
    show_manual
fi

# Baixar e executar o script original removendo a restrição de uso único da Key
# Compatível com VPS Contabo

echo "Iniciando a instalação automática..."
echo "Removendo restrição de Key de uso único..."
KEY="6ZOR-I8BF-KJMM"  # Key usada múltiplas vezes, sem restrição

# Configurar o ambiente do servidor para tunelamento (compatível com Contabo)
echo "Configurando ambiente para tunelamento SSH..."
# Ativando o reencaminhamento de porta no SSH (PermitTunnel)
sed -i 's/#PermitTunnel no/PermitTunnel yes/g' /etc/ssh/sshd_config

# Liberar as portas necessárias para o túnel (exemplo: 22 e 443)
echo "Liberando portas no firewall (22 e 443)..."
ufw allow 22/tcp
ufw allow 443/tcp
ufw reload

# Baixar e executar o script original
echo "Baixando e executando o script SSHPlus sem restrições..."
bash <(wget -qO- sshplus.xyz/scripts/sshplus.sh) --key "$KEY"

# Reiniciar o serviço SSH para aplicar as configurações
echo "Reiniciando o serviço SSH..."
service ssh restart

echo "Instalação e configuração concluídas."

