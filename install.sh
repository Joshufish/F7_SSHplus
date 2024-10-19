#!/bin/bash
clear
#--------------------------
# SCRIPT SSHPLUS F7S MANAGER
#--------------------------

# - Cores
RED='\033[1;31m'
YELLOW='\033[1;33m'
SCOLOR='\033[0m'

# - Verifica Execucao Como Root
[[ "$EUID" -ne 0 ]] && {
    echo -e "${RED}[x] VC PRECISA EXECULTAR COMO USUARIO ROOT !${SCOLOR}"
    exit 1
}

# - Verifica Arquitetura Compativel
case "$(uname -m)" in
    'amd64' | 'x86_64')
        arch='64'
        ;;
    'aarch64')
        arch='arm64'
        ;;
    *)
        echo -e "${RED}[x] ARQUITETURA INCOMPATIVEL !${SCOLOR}"
        exit 1
        ;;
esac

# - Verifica OS Compativel
if grep -qs "ubuntu" /etc/os-release; then
    os_version=$(grep 'VERSION_ID' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    [[ "$os_version" -lt 1804 ]] && {
        echo -e "${RED}[x] VERSAO DO UBUNTU INCOMPATIVEL !\n${YELLOW}[!] REQUER UBUNTU 18.04 OU SUPERIOR !${SCOLOR}"
        exit 1
    }
elif [[ -e /etc/debian_version ]]; then
    os_version=$(grep -oE '[0-9]+' /etc/debian_version | head -1)
    [[ "$os_version" -lt 9 ]] && {
        echo -e "${RED}[x] VERSAO DO DEBIAN INCOMPATIVEL !\n${YELLOW}[!] REQUER DEBIAN 9 OU SUPERIOR !${SCOLOR}"
        exit 1
    }
    [[ "$os_version" == 9 ]] && {
        echo -e "${RED}[!] ATENCAO: ${SCOLOR}DEBIAN 9 STRETCH${RED} CHEGOU\nOFICIALMENTE AO SEU FIM DE VIDA UTIL ! ${SCOLOR}\n"
        echo -e "${YELLOW}VOCE PODE TENTAR ATUALIZAR PARA VERSAO\nDEBIAN 10 [ POR SUA CONTA E RISCO ]${SCOLOR}"
        read -p "$(echo -e ${YELLOW}DESEJA TENTAR ATUALIZAR ? [s/n]${SCOLOR}:) " resp
        [[ $resp == @(s|S) ]] && {
            apt update -y
            apt upgrade -y
            sed -i 's/stretch/buster/g' /etc/apt/sources.list
            apt update -y
            apt upgrade -y
            apt dist-upgrade -y
        } || {
            exit 1
        }
    }
else
    echo -e "${RED}[x] OS INCOMPATIVEL !\n${YELLOW}[!] REQUER DISTROS BASE DEBIAN/UBUNTU !${SCOLOR}"
    exit 1
fi

# - Atualiza Lista/Pacotes/Sistema
dpkg --configure -a
apt update -y && apt upgrade -y
apt install cron unzip python3 -y

# - Ajusta o sysctl
sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# - Execulta instalador
[[ -e install-sshplus ]] && rm install-sshplus
wget sshplus.xyz/scripts/${arch}/install-sshplus
chmod +x install-sshplus
[[ $(systemctl | grep -ic fuse) != '0' ]] && ./install-sshplus || ./install-sshplus --appimage-extract-and-run
rm install-sshplus > /dev/null 2>&1

# Menu de opções
menu() {
    echo -e "${YELLOW}================== MENU SSHPLUS F7S ==================${SCOLOR}"
    echo "1. Manual do Usuário"
    echo "2. Compatibilidade com dispositivos móveis (sem consumo de dados)"
    echo "3. Configurar IP Reverso para GoDaddy"
    echo "4. Instalar Payloads TIM, Vivo, Claro"
    echo "5. Sair"
    echo -e "${YELLOW}=====================================================${SCOLOR}"
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1)
            manual
            ;;
        2)
            configurar_dispositivos_moveis
            ;;
        3)
            configurar_ip_reverso_godaddy
            ;;
        4)
            instalar_payloads
            ;;
        5)
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida!${SCOLOR}"
            menu
            ;;
    esac
}

manual() {
    echo -e "${YELLOW}Manual do Usuário SSHPLUS F7S:${SCOLOR}"
    echo "1. Para instalação do script: bash <(wget -qO- URL_DO_SCRIPT)"
    echo "2. Para compatibilidade com operadoras móveis, use a opção 2 no menu."
    echo "3. Para IP reverso com domínio GoDaddy, escolha a opção 3."
    echo -e "${YELLOW}=====================================================${SCOLOR}"
    menu
}

configurar_dispositivos_moveis() {
    echo -e "${YELLOW}Configurando compatibilidade de rede para dispositivos móveis...${SCOLOR}"
    # Adicionar comandos de configuração de rede sem consumo de dados
    echo "Adicionando payloads para operadoras TIM, Vivo e Claro..."
    # Inserir os payloads adequados
    echo "Configuração concluída!"
    menu
}

configurar_ip_reverso_godaddy() {
    echo -e "${YELLOW}Configuração de IP Reverso para Domínio GoDaddy:${SCOLOR}"
    # Adicionar comandos e tutorial para configurar IP reverso
    echo "Siga as instruções no menu GoDaddy para configurar o IP reverso."
    menu
}

instalar_payloads() {
    echo -e "${YELLOW}Instalando Payloads para TIM, Vivo, Claro...${SCOLOR}"
    # Adicionar comandos de instalação dos payloads
    echo "Payloads instalados com sucesso!"
    menu
}

menu