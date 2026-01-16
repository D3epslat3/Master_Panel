#!/bin/bash

# ==========================================
# MASTER CONTROL PANEL - V11.3 (Universal Extractor)
# ==========================================

# --- CORES ---
cat <<EOF > /tmp/.dialogrc_catppuccin
aspect = 0
separate_widget = ""
tab_len = 0
visit_items = OFF
use_shadow = OFF
use_colors = ON
screen_color = (WHITE,BLACK,ON)
shadow_color = (BLACK,BLACK,ON)
dialog_color = (WHITE,BLACK,OFF)
title_color = (BLUE,BLACK,ON)
border_color = (BLUE,BLACK,ON)
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (BLACK,WHITE,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (RED,WHITE,OFF)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (BLACK,WHITE,OFF)
inputbox_color = (WHITE,BLACK,OFF)
inputbox_border_color = (BLUE,BLACK,ON)
searchbox_color = (WHITE,BLACK,OFF)
searchbox_title_color = (BLUE,BLACK,ON)
searchbox_border_color = (BLUE,BLACK,ON)
position_indicator_color = (BLUE,BLACK,ON)
menubox_color = (WHITE,BLACK,OFF)
menubox_border_color = (BLUE,BLACK,ON)
item_color = (WHITE,BLACK,OFF)
item_selected_color = (WHITE,BLUE,ON)
tag_color = (BLUE,BLACK,ON)
tag_selected_color = (WHITE,BLUE,ON)
tag_key_color = (RED,BLACK,OFF)
tag_key_selected_color = (WHITE,BLUE,ON)
check_color = (WHITE,BLACK,OFF)
check_selected_color = (WHITE,BLUE,ON)
uarrow_color = (BLUE,BLACK,ON)
darrow_color = (BLUE,BLACK,ON)
itemhelp_color = (WHITE,BLACK,OFF)
form_active_text_color = (WHITE,BLUE,ON)
form_text_color = (WHITE,BLACK,OFF)
form_item_readonly_color = (CYAN,BLACK,OFF)
gauge_color = (BLUE,BLACK,ON)
border2_color = (BLUE,BLACK,ON)
inputbox_border2_color = (BLUE,BLACK,ON)
searchbox_border2_color = (BLUE,BLACK,ON)
menubox_border2_color = (BLUE,BLACK,ON)
EOF
export DIALOGRC=/tmp/.dialogrc_catppuccin

# --- ARQUIVOS HYPRLAND ---
USER_BINDS="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
SYSTEM_BINDS="$HOME/.config/hypr/configs/Keybinds.conf"
BACKUP_DIR="$HOME/.config/hypr/UserConfigs/backups"
mkdir -p "$BACKUP_DIR"

# --- DEPENDÊNCIAS ---
DEPENDENCIES=(dialog curl git grep sed ip btop arp-scan nmap tar)
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        if command -v pacman &>/dev/null; then sudo pacman -S --noconfirm "$cmd" &>/dev/null
        elif command -v dnf &>/dev/null; then sudo dnf install -y "$cmd" &>/dev/null
        elif command -v apt &>/dev/null; then sudo apt update && sudo apt install -y "$cmd" &>/dev/null
        fi
    fi
done

# --- DETECÇÃO NIX E REPOS ---
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh';
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi

if command -v dnf &>/dev/null || command -v pacman &>/dev/null || command -v apt &>/dev/null; then REPO_NATIVE="on"; else REPO_NATIVE="off"; fi
if command -v flatpak &>/dev/null; then REPO_FLATPAK="on"; else REPO_FLATPAK="off"; fi
if command -v snap &>/dev/null; then REPO_SNAP="on"; else REPO_SNAP="off"; fi
if command -v yay &>/dev/null || command -v paru &>/dev/null; then REPO_AUR="on"; else REPO_AUR="off"; fi
if command -v nix-env &>/dev/null || [ -d "/nix" ]; then REPO_NIX="off"; else REPO_NIX="off"; fi

# --- OMNI INSTALLER ---
configure_repos() {
    OPTIONS=()
    if command -v dnf &>/dev/null; then OPTIONS+=("NATIVE" "Fedora (DNF)" "$REPO_NATIVE"); fi
    if command -v pacman &>/dev/null; then OPTIONS+=("NATIVE" "Arch (Pacman)" "$REPO_NATIVE"); fi
    if command -v apt &>/dev/null; then OPTIONS+=("NATIVE" "Debian (APT)" "$REPO_NATIVE"); fi
    if command -v flatpak &>/dev/null; then OPTIONS+=("FLATPAK" "Flathub" "$REPO_FLATPAK"); fi
    if command -v snap &>/dev/null; then OPTIONS+=("SNAP" "Snap Store" "$REPO_SNAP"); fi
    if command -v yay &>/dev/null; then OPTIONS+=("AUR" "AUR (Yay)" "$REPO_AUR"); fi
    if command -v paru &>/dev/null; then OPTIONS+=("AUR" "AUR (Paru)" "$REPO_AUR"); fi
    if command -v nix-env &>/dev/null || [ -d "/nix" ]; then OPTIONS+=("NIX" "Nixpkgs" "$REPO_NIX"); fi
    CHOICES=$(dialog --title "Configurar Fontes" --checklist "Onde buscar pacotes?" 15 60 5 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
    REPO_NATIVE="off"; REPO_FLATPAK="off"; REPO_SNAP="off"; REPO_AUR="off"; REPO_NIX="off"
    if [[ $CHOICES == *"NATIVE"* ]]; then REPO_NATIVE="on"; fi
    if [[ $CHOICES == *"FLATPAK"* ]]; then REPO_FLATPAK="on"; fi
    if [[ $CHOICES == *"AUR"* ]]; then REPO_AUR="on"; fi
    if [[ $CHOICES == *"SNAP"* ]]; then REPO_SNAP="on"; fi
    if [[ $CHOICES == *"NIX"* ]]; then REPO_NIX="on"; fi
}
omni_search() {
    QUERY=$(dialog --inputbox "  Digite o nome do software:" 10 60 3>&1 1>&2 2>&3); if [ -z "$QUERY" ]; then return; fi
    RES_FILE="/tmp/pkg_results.txt"; rm -f $RES_FILE; touch $RES_FILE
    dialog --infobox "Buscando '$QUERY'..." 6 50
    PIDS=""
    if [ "$REPO_NATIVE" == "on" ]; then
        if command -v dnf &>/dev/null; then (timeout 15 dnf search -q "$QUERY" 2>/dev/null | awk '{print "DNF:"$1 " [Fedora]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v pacman &>/dev/null; then (timeout 15 pacman -Ss "$QUERY" | grep "/" | awk '{print "PAC:"$1 " [Arch]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v apt &>/dev/null; then (timeout 15 apt search "$QUERY" 2>/dev/null | grep "/" | cut -d/ -f1 | awk '{print "APT:"$1 " [Debian]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        fi
    fi
    if [ "$REPO_AUR" == "on" ]; then
        if command -v yay &>/dev/null; then (timeout 20 yay -Ss "$QUERY" | grep "^aur" | awk '{print "YAY:"$1 " [AUR]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v paru &>/dev/null; then (timeout 20 paru -Ss "$QUERY" | grep "^aur" | awk '{print "PARU:"$1 " [AUR]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        fi
    fi
    if [ "$REPO_FLATPAK" == "on" ]; then (timeout 15 flatpak search "$QUERY" --columns=application | awk '{print "FLAT:"$1 " [Flatpak]"}' >> $RES_FILE) & PIDS="$PIDS $!"; fi
    if [ "$REPO_SNAP" == "on" ]; then (timeout 15 snap find "$QUERY" | awk 'NR>1 {print "SNAP:"$1 " [Snap]"}' >> $RES_FILE) & PIDS="$PIDS $!"; fi
    if [ "$REPO_NIX" == "on" ]; then
        if command -v nix-env &>/dev/null; then (timeout 25 nix-env -qaP ".*$QUERY.*" 2>/dev/null | head -n 15 | awk '{print "NIX:"$1 " [NixPkg]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif [ -f "/nix/var/nix/profiles/default/bin/nix-env" ]; then (timeout 25 /nix/var/nix/profiles/default/bin/nix-env -qaP ".*$QUERY.*" 2>/dev/null | head -n 15 | awk '{print "NIX:"$1 " [NixPkg]"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif [ -f "$HOME/.nix-profile/bin/nix-env" ]; then (timeout 25 $HOME/.nix-profile/bin/nix-env -qaP ".*$QUERY.*" 2>/dev/null | head -n 15 | awk '{print "NIX:"$1 " [NixPkg]"}' >> $RES_FILE) & PIDS="$PIDS $!"; fi
    fi
    wait $PIDS
    if [ ! -s $RES_FILE ]; then dialog --msgbox "Nenhum pacote encontrado." 6 40; return; fi
    LIST_ITEMS=$(cat $RES_FILE | sort | uniq | tr '\n' ' ')
    SELECTED=$(eval dialog --title \"Resultados\" --menu \"Selecione:\" 22 80 12 $LIST_ITEMS 3>&1 1>&2 2>&3)
    if [ ! -z "$SELECTED" ]; then
        TYPE=$(echo "$SELECTED" | cut -d':' -f1); PKG=$(echo "$SELECTED" | cut -d':' -f2)
        clear; echo "Instalando: $PKG"; case $TYPE in DNF) sudo dnf install "$PKG" ;; PAC) CLEAN=$(echo "$PKG"|cut -d'/' -f2); sudo pacman -S "$CLEAN" ;; YAY) CLEAN=$(echo "$PKG"|cut -d'/' -f2); yay -S "$CLEAN" ;; APT) sudo apt install "$PKG" ;; FLAT) flatpak install "$PKG" ;; SNAP) sudo snap install "$PKG" ;; NIX) if command -v nix-env &>/dev/null; then nix-env -iA "$PKG"; else $HOME/.nix-profile/bin/nix-env -iA "$PKG"; fi ;; esac
        echo ""; read -p "Pressione Enter..."
    fi
}
omni_menu() {
    while true; do OPT=$(dialog --title "Omni-Installer" --menu "Opções" 20 70 10 "1" "     Buscar e Instalar" "2" "     Configurar Repositórios" "3" "     Voltar" 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break; case $OPT in 1) omni_search ;; 2) configure_repos ;; 3) break ;; esac; done
}

# --- OUTRAS FERRAMENTAS ---
disk_tools() {
    while true; do D_OPT=$(dialog --title "Ferramentas de Disco" --menu "Escolha:" 20 70 10 "1" "     Geral (df -h)" "2" "     Tamanho Pastas" "3" "     Maiores Arquivos" "4" "     NCDU" "5" "     Voltar" 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break; case $D_OPT in 1) df -h|grep -v "loop"|grep -v "tmpfs" > /tmp/df.txt; dialog --textbox /tmp/df.txt 20 80; rm /tmp/df.txt;; 2) dialog --infobox "Calculando..." 5 40; du -h --max-depth=1 "$HOME" 2>/dev/null|sort -rh|head -n 20 > /tmp/fol.txt; dialog --textbox /tmp/fol.txt 20 80; rm /tmp/fol.txt;; 3) dialog --infobox "Varrendo..." 5 40; du -ahx "$HOME" 2>/dev/null|sort -rh|head -n 20 > /tmp/fil.txt; dialog --textbox /tmp/fil.txt 20 80; rm /tmp/fil.txt;; 4) command -v ncdu &>/dev/null && { clear; ncdu "$HOME"; } || dialog --msgbox "Instale o ncdu!" 6 30;; 5) break;; esac; done
}
docker_tools() {
    [ ! -x "$(command -v docker)" ] && { dialog --msgbox "Docker ausente." 6 30; return; }; while true; do containers=$(docker ps -a --format "{{.ID}}:{{.Names}} ({{.Status}})"|awk -F: '{printf "%s \"%s\" ", $1, $2}'); [ -z "$containers" ] && { dialog --msgbox "Sem containers." 6 30; return; }; CID=$(eval dialog --menu \"Containers:\" 20 70 10 $containers 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break; [ ! -z "$CID" ] && { act=$(dialog --menu "Ação:" 15 50 4 "start" "Start" "stop" "Stop" "restart" "Restart" "logs" "Logs" 3>&1 1>&2 2>&3); case $act in logs) docker logs "$CID"|tail -n 50 > /tmp/l; dialog --textbox /tmp/l 20 80; rm /tmp/l;; *) clear; sudo docker "$act" "$CID"; sleep 1;; esac; }; done
}
network_tools() {
    while true; do OPT=$(dialog --menu "Rede" 20 70 10 "1" "    Scanner" "2" "    Firewall" "3" "    Ping" "4" "    Voltar" 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break; case $OPT in 1) dialog --infobox "Scan..." 5 30; sudo arp-scan --localnet --ignoredups --retry=2 > /tmp/s; opts=(); while read l; do ip=$(echo "$l"|grep -oP '^\d{1,3}(\.\d{1,3}){3}'); [ ! -z "$ip" ] && opts+=("$ip" "Dev"); done < /tmp/s; sel=$(dialog --menu "IPs:" 20 70 10 "${opts[@]}" 3>&1 1>&2 2>&3); [ ! -z "$sel" ] && sudo nmap -F "$sel" | dialog --programbox 20 70 ;; 2) sudo iptables -L INPUT -n > /tmp/f; dialog --textbox /tmp/f 20 80 ;; 3) ping -c 3 8.8.8.8 > /tmp/p; dialog --textbox /tmp/p 20 80 ;; 4) break ;; esac; done
}

# --- FUNÇÕES DE TEMA (ATUALIZADAS V11.3) ---

open_nwg_look() {
    if ! command -v nwg-look &>/dev/null; then
        if dialog --yesno "nwg-look não encontrado. Instalar?" 6 40; then
            clear
            if command -v pacman &>/dev/null; then sudo pacman -S --noconfirm nwg-look
            elif command -v yay &>/dev/null; then yay -S nwg-look
            else dialog --msgbox "Instale manualmente: nwg-look" 6 40; return; fi
        else return; fi
    fi
    clear; nwg-look &
}

install_icons_tar() {
    FILE=$(dialog --title "Selecione o arquivo .tar*" --fselect "$HOME/Downloads/" 10 70 3>&1 1>&2 2>&3)
    [ -z "$FILE" ] && return

    # Verificação Universal
    if [[ "$FILE" != *.tar* ]]; then
        dialog --msgbox "Arquivo deve ser .tar, .tar.gz, .tar.xz ou .tar.bz2!" 6 50; return
    fi

    if [ ! -f "$FILE" ]; then dialog --msgbox "Arquivo não existe." 6 40; return; fi

    DEST="$HOME/.local/share/icons"
    mkdir -p "$DEST"
    
    dialog --infobox "Extraindo para $DEST..." 5 50
    # O comando -xf detecta automaticamente o formato (xz, gz, bzip2)
    tar -xf "$FILE" -C "$DEST"
    
    if [ $? -eq 0 ]; then
        dialog --msgbox "Sucesso!\nÍcones instalados em: $DEST\n\nAbra o nwg-look para aplicar." 10 50
    else
        dialog --msgbox "Erro ao extrair arquivo." 6 40
    fi
}

sysadmin_manager() {
    while true; do OPT=$(dialog --title "SysAdmin" --menu "Opções" 20 70 10 \
    "1" "     Abrir nwg-look (Temas)" \
    "2" "     Instalar Ícones (Qualquer Tar)" \
    "3" "     Rede & WiFi" \
    "4" "     Docker Manager" \
    "5" "     Analise de Disco" \
    "6" "     Serviços" \
    "7" "     Atualizar Sistema" \
    "8" "     Logs de Erro" \
    "9" "     Monitor (Btop)" \
    "10" "    Voltar" 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break
    case $OPT in
        1) open_nwg_look ;;
        2) install_icons_tar ;;
        3) network_tools ;; 
        4) docker_tools ;; 
        5) disk_tools ;; 
        6) s=$(dialog --inputbox "Serviço:" 10 40 3>&1 1>&2 2>&3); [ ! -z "$s" ] && { clear; sudo systemctl status "$s"; read -p "Enter..."; } ;; 
        7) clear; command -v pacman &>/dev/null && sudo pacman -Syu || sudo dnf update; read -p "Enter..." ;; 
        8) journalctl -p 3 -xb > /tmp/err.txt; dialog --textbox /tmp/err.txt 20 80; rm /tmp/err.txt ;; 
        9) clear; btop ;; 
        10) return ;; 
    esac; done
}

spicetify_tools() {
    while true; do OPT=$(dialog --menu "Spicetify" 20 70 10 "1" "     Instalar Spicetify" "2" "     Instalar Marketplace" "3" "     Fix Flatpak Perms" "4" "     Instalar Tema (Catppuccin)" "5" "     Force Apply" "6" "     Fix Audio" "7" "     Voltar" 3>&1 1>&2 2>&3); [ $? -ne 0 ] && break; case $OPT in 1) clear; curl -fsSL https://spicetify.app/install.sh | sh; export PATH=$PATH:$HOME/.spicetify; read -p "Instalado. Enter..." ;; 2) clear; curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh; read -p "Marketplace instalado. Enter..." ;; 3) clear; sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/ -R; read -p "OK..." ;; 4) clear; d="$(dirname "$(spicetify -c)")/Themes"; mkdir -p "$d"; cd "$d"; git clone https://github.com/catppuccin/spicetify.git catppuccin 2>/dev/null; cp -r catppuccin/* .; spicetify config current_theme catppuccin color_scheme mocha; read -p "Tema baixado. Use 'Force Apply'..." ;; 5) clear; spicetify restore backup apply; read -p "OK..." ;; 6) systemctl --user restart pipewire wireplumber; dialog --msgbox "OK" 6 20 ;; 7) break ;; esac; done
}

# ==========================================
# HYPRLAND MANAGER
# ==========================================
hyprland_tools() {
    [ ! -f "$USER_BINDS" ] && { dialog --msgbox "Config customizada não encontrada em:\n$USER_BINDS" 8 50; return; }
    while true; do
        OPT=$(dialog --menu "Hyprland" 20 70 10 \
        "1" "     Add Bind (Custom)" \
        "2" "     Del Bind (Custom)" \
        "3" "     List Binds (Custom)" \
        "4" "     Editar Binds do SISTEMA" \
        "5" "     Restore Backup" \
        "6" "     Reload" \
        "7" "     Voltar" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && break
        case $OPT in
            1)
                MODS=$(dialog --checklist "Modificadores:" 15 50 5 "\$mainMod" "Super" ON "SHIFT" "" OFF "CTRL" "" OFF "ALT" "" OFF 3>&1 1>&2 2>&3)
                MODS_CLEAN=$(echo $MODS | sed 's/"//g')
                if [ -z "$MODS_CLEAN" ]; then continue; fi
                KEY=$(dialog --inputbox "Tecla (ex: Q, 1, Return):" 10 40 3>&1 1>&2 2>&3)
                if [ -z "$KEY" ]; then continue; fi
                CMD=$(dialog --inputbox "Comando (ex: htop, kitty):" 10 40 3>&1 1>&2 2>&3)
                if [ -z "$CMD" ]; then continue; fi

                DESC=$(dialog --inputbox "Descrição (Obrigatória para o plugin):" 10 40 3>&1 1>&2 2>&3)
                if [ -z "$DESC" ]; then DESC="Custom Bind"; fi

                IS_TERM="NO"
                if dialog --yesno "Rodar no terminal?" 8 60; then IS_TERM="YES"; fi
                FINAL_CMD="$CMD"
                if [ "$IS_TERM" == "YES" ]; then
                    MY_TERM=$(grep "\$terminal =" "$HOME/.config/hypr/hyprland.conf" | cut -d'=' -f2 | xargs)
                    if [ -z "$MY_TERM" ]; then
                        if command -v kitty &>/dev/null; then MY_TERM="kitty"; elif command -v alacritty &>/dev/null; then MY_TERM="alacritty"; else MY_TERM="xterm"; fi
                    fi
                    case "$MY_TERM" in "gnome-terminal") FINAL_CMD="$MY_TERM -- $CMD" ;; *) FINAL_CMD="$MY_TERM -e $CMD" ;; esac
                fi

                mkdir -p "$BACKUP_DIR"
                cp "$USER_BINDS" "$BACKUP_DIR/bkp_$(date +%s).conf"
                echo "" >> "$USER_BINDS"
                echo "bind = $MODS_CLEAN, $KEY, exec, $FINAL_CMD #\"$DESC\"" >> "$USER_BINDS"
                dialog --msgbox "Adicionado com formato do plugin:\n#\"$DESC\"" 8 60
                ;;
            2)
                grep -n "^bind =" "$USER_BINDS" > /tmp/br
                opts=(); while read l; do ln=$(echo "$l"|cut -d: -f1); tx=$(echo "$l"|cut -d: -f2-|cut -c 1-45); opts+=("$ln" "$tx"); done < /tmp/br
                rm /tmp/br
                if [ ${#opts[@]} -eq 0 ]; then dialog --msgbox "Nada encontrado." 6 30; continue; fi
                del=$(dialog --menu "Apagar:" 20 75 10 "${opts[@]}" 3>&1 1>&2 2>&3)
                [ ! -z "$del" ] && sed -i "${del}d" "$USER_BINDS" && dialog --msgbox "Apagado." 6 20
                ;;
            3) grep "bind =" "$USER_BINDS" > /tmp/b; dialog --textbox /tmp/b 20 80; rm /tmp/b ;;
            4)
                if [ -f "$SYSTEM_BINDS" ]; then
                    if command -v micro &>/dev/null; then EDITOR="micro"; else EDITOR="nano"; fi
                    clear; echo "Abrindo arquivo do sistema..."; read -p "Enter..."
                    $EDITOR "$SYSTEM_BINDS"
                else
                    dialog --msgbox "Não encontrado: $SYSTEM_BINDS" 8 50
                fi
                ;;
            5) bk=$(ls "$BACKUP_DIR"|sort -r|head -10|while read l; do echo "$l" "$l"; done|xargs dialog --menu "Restaurar:" 15 60 5 3>&1 1>&2 2>&3); [ ! -z "$bk" ] && cp "$BACKUP_DIR/$bk" "$USER_BINDS" ;;
            6) hyprctl reload ;;
            7) break ;;
        esac
    done
}

# --- MENU PRINCIPAL ---
while true; do
    MAIN=$(dialog --title "Master Panel v11.3" --menu "Painel de Controle" 20 70 10 \
    "1" "     Omni-Installer" \
    "2" "     SysAdmin & Temas" \
    "3" "     Spicetify Tools" \
    "4" "     Hyprland Manager" \
    "5" "     Limpeza Rápida" \
    "6" "     Sair" 3>&1 1>&2 2>&3)
    [ $? -ne 0 ] && break; case $MAIN in 1) omni_menu ;; 2) sysadmin_manager ;; 3) spicetify_tools ;; 4) hyprland_tools ;; 5) clear; flatpak uninstall --unused; rm -rf ~/.cache/thumbnails/*; dialog --msgbox "Limpo!" 6 20 ;; 6) break ;; esac
done
clear; rm /tmp/.dialogrc_catppuccin
