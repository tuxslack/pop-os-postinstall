#!/usr/bin/env bash
#
# pos-os-postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
#
# Website:       https://diolinux.com.br
# Autor:         Dionatan Simioni
# Colaboração:   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# ------------------------------------------------------------------------ #
#
# COMO USAR?
#   $ ./pos-os-postinstall.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #





clear

# -------------------------------------------------------------------------------------------------

# Verificar se os programas estão instalados:

which sudo        1> /dev/null || exit 1
which apt         1> /dev/null || exit 2
which ping        1> /dev/null || exit 3
which wget        1> /dev/null || exit 4
which dpkg        1> /dev/null || exit 5
which flatpak     1> /dev/null || exit 6
which snap        1> /dev/null || exit 7
which nautilus    1> /dev/null || exit 8

# -------------------------------------------------------------------------------------------------


set -e

##URLS

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_4K_VIDEO_DOWNLOADER="https://dl.4kdownload.com/app/4kvideodownloader_4.20.0-1_amd64.deb?source=website"
URL_INSYNC="https://d2t3ff60b2tol4.cloudfront.net/builds/insync_3.7.2.50318-impish_amd64.deb"
URL_SYNOLOGY_DRIVE="https://global.download.synology.com/download/Utility/SynologyDriveClient/3.0.3-12689/Ubuntu/Installer/x86_64/synology-drive-client-12689.x86_64.deb"


##DIRETÓRIOS E ARQUIVOS

DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FILE="$HOME/.config/gtk-3.0/bookmarks"


#CORES

VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'


#FUNÇÕES

# Atualizando repositório e fazendo atualização do sistema

apt_update(){
  sudo apt update && sudo apt dist-upgrade -y
}

# -------------------------------------------------------------------------------- #
# -------------------------------TESTES E REQUISITOS----------------------------------------- #

# Internet conectando?

testes_internet(){


# Para verificar o arquivo /etc/resolv.conf

if ! ping -c 1 www.google.com.br -q &> /dev/null; then

  echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${SEM_COR}"
  
  exit 1
  
else

  echo -e "${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}"
  
fi

}

# ------------------------------------------------------------------------------ #


## Removendo travas eventuais do apt ##

travas_apt(){

  sudo rm -Rf /var/lib/dpkg/lock-frontend
  sudo rm -Rf /var/cache/apt/archives/lock
  
}

## Adicionando/Confirmando arquitetura de 32 bits ##
add_archi386(){
sudo dpkg --add-architecture i386
}
## Atualizando o repositório ##
just_apt_update(){
sudo apt update -y
}

##DEB SOFTWARES TO INSTALL

PROGRAMAS_PARA_INSTALAR=(
  snapd
  winff
  virtualbox
  ratbagd
  gparted
  timeshift
  gufw
  synaptic
  solaar
  vlc
  code
  gnome-sushi 
  folder-color
  git
  wget
  ubuntu-restricted-extras
  v4l2loopback-utils
 
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##

install_debs(){

echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

mkdir "$DIRETORIO_DOWNLOADS"
wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_4K_VIDEO_DOWNLOADER" -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_INSYNC"              -P "$DIRETORIO_DOWNLOADS"
wget -c "$URL_SYNOLOGY_DRIVE"      -P "$DIRETORIO_DOWNLOADS"

## Instalando pacotes .deb baixados na sessão anterior ##
echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"
sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

# Instalar programas no apt
echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done

}

## Instalando pacotes Flatpak ##

install_flatpaks(){

echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"

flatpak install flathub com.obsproject.Studio -y
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub com.bitwarden.desktop -y
flatpak install flathub org.telegram.desktop -y
flatpak install flathub org.freedesktop.Piper -y
flatpak install flathub org.chromium.Chromium -y
flatpak install flathub org.gnome.Boxes -y
flatpak install flathub org.onlyoffice.desktopeditors -y
flatpak install flathub org.qbittorrent.qBittorrent -y
flatpak install flathub org.flameshot.Flameshot -y
flatpak install flathub org.electrum.electrum -y
}

## Instalando pacotes Snap ##

install_snaps(){

echo -e "${VERDE}[INFO] - Instalando pacotes snap${SEM_COR}"

sudo snap install authy

}


# -------------------------------------------------------------------------- #
# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #


## Finalização, atualização e limpeza##

system_clean(){

apt_update -y
flatpak update -y
sudo apt autoclean -y
sudo apt autoremove -y
nautilus -q
}


# -------------------------------------------------------------------------- #
# ----------------------------- CONFIGS EXTRAS ----------------------------- #

# Cria pastas para produtividade no nautilus

extra_config(){


mkdir -p $HOME/TEMP
mkdir -p $HOME/EDITAR 
mkdir -p $HOME/Resolve
mkdir -p $HOME/AppImage
mkdir -p $HOME/Vídeos/'OBS Rec'

# Adiciona atalhos ao Nautilus

if test -f "$FILE"; then

    echo "$FILE já existe"
    
else

    echo "$FILE não existe, criando..."
    
    touch $HOME/.config/gkt-3.0/bookmarks
fi

echo "file://$HOME/EDITAR 🔵 EDITAR" >> $FILE
echo "file://$HOME/AppImage" >> $FILE
echo "file://$HOME/Resolve 🔴 Resolve" >> $FILE
echo "file://$HOME/TEMP 🕖 TEMP" >> $FILE
}

# -------------------------------------------------------------------------------- #
# -------------------------------EXECUÇÃO----------------------------------------- #

travas_apt
testes_internet
travas_apt
apt_update
travas_apt
add_archi386
just_apt_update
install_debs
install_flatpaks
install_snaps
extra_config
apt_update
system_clean

## finalização

  echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"
