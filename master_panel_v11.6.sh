#!/bin/bash

# ==========================================
# MASTER CONTROL PANEL - V12.1 (Hex Icons)
# ==========================================

# --- FORÇAR UTF-8 E LOCALE ---
# Isso é crucial para os ícones aparecerem
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# --- ÍCONES SEGUROS (Gerados via Hex) ---
I_PKG=$(printf '\uf487')  # 
I_SYS=$(printf '\uf0ad')  # 
I_SPT=$(printf '\uf1bc')  # 
I_WIN=$(printf '\uf2d0')  # 
I_CLN=$(printf '\uf1f8')  # 
I_EXT=$(printf '\uf08b')  # 
I_SRC=$(printf '\uf002')  # 
I_CFG=$(printf '\uf013')  # 
I_NET=$(printf '\uf1eb')  # 
I_DOC=$(printf '\uf328')  # 
I_DSK=$(printf '\uf0a0')  # 
I_THE=$(printf '\ue22b')  # 

# --- CORES (Catppuccin Mocha) ---
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

# --- ARQUIVOS & CAMINHOS ---
HYPR_USER="$HOME/.config/hypr/UserConfigs/UserKeybinds.conf"
HYPR_SYS="$HOME/.config/hypr/configs/Keybinds.conf"
HYPR_BACKUP="$HOME/.config/hypr/UserConfigs/backups"

NIRI_USER="$HOME/.config/niri/UserConfigs/UserKeybinds.kdl"
NIRI_SYS="$HOME/.config/niri/config.kdl"
NIRI_BACKUP="$HOME/.config/niri/backups"

mkdir -p "$HYPR_BACKUP" "$NIRI_BACKUP" "$(dirname "$NIRI_USER")"

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

# ==========================================
# 1. OMNI INSTALLER
# ==========================================
configure_repos() {
    OPTIONS=()
    if command -v dnf &>/dev/null; then OPTIONS+=("NATIVE" "Fedora DNF" "$REPO_NATIVE"); fi
    if command -v pacman &>/dev/null; then OPTIONS+=("NATIVE" "Arch Pacman" "$REPO_NATIVE"); fi
    if command -v apt &>/dev/null; then OPTIONS+=("NATIVE" "Debian APT" "$REPO_NATIVE"); fi
    if command -v flatpak &>/dev/null; then OPTIONS+=("FLATPAK" "Flathub" "$REPO_FLATPAK"); fi
    if command -v snap &>/dev/null; then OPTIONS+=("SNAP" "Snap Store" "$REPO_SNAP"); fi
    if command -v yay &>/dev/null; then OPTIONS+=("AUR" "AUR (Yay)" "$REPO_AUR"); fi
    if command -v paru &>/dev/null; then OPTIONS+=("AUR" "AUR (Paru)" "$REPO_AUR"); fi
    if command -v nix-env &>/dev/null || [ -d "/nix" ]; then OPTIONS+=("NIX" "Nixpkgs" "$REPO_NIX"); fi
    
    CHOICES=$(dialog --stdout --title "Fontes de Pacotes" --checklist "Selecione:" 15 60 5 "${OPTIONS[@]}")
    
    REPO_NATIVE="off"; REPO_FLATPAK="off"; REPO_SNAP="off"; REPO_AUR="off"; REPO_NIX="off"
    if [[ $CHOICES == *"NATIVE"* ]]; then REPO_NATIVE="on"; fi
    if [[ $CHOICES == *"FLATPAK"* ]]; then REPO_FLATPAK="on"; fi
    if [[ $CHOICES == *"AUR"* ]]; then REPO_AUR="on"; fi
    if [[ $CHOICES == *"SNAP"* ]]; then REPO_SNAP="on"; fi
    if [[ $CHOICES == *"NIX"* ]]; then REPO_NIX="on"; fi
}

omni_search() {
    QUERY=$(dialog --stdout --inputbox "$I_SRC  Buscar Software:" 10 60)
    [ -z "$QUERY" ] && return
    RES_FILE="/tmp/pkg_results.txt"; rm -f $RES_FILE; touch $RES_FILE
    dialog --infobox "Pesquisando..." 6 50
    PIDS=""
    
    if [ "$REPO_NATIVE" == "on" ]; then
        if command -v dnf &>/dev/null; then (timeout 15 dnf search -q "$QUERY" 2>/dev/null | awk '{print "DNF:"$1 " [Fedora] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v pacman &>/dev/null; then (timeout 15 pacman -Ss "$QUERY" | grep "/" | awk '{print "PAC:"$1 " [Arch] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v apt &>/dev/null; then (timeout 15 apt search "$QUERY" 2>/dev/null | grep "/" | cut -d/ -f1 | awk '{print "APT:"$1 " [Debian] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        fi
    fi
    if [ "$REPO_AUR" == "on" ]; then
        if command -v yay &>/dev/null; then (timeout 20 yay -Ss "$QUERY" | grep "^aur" | awk '{print "YAY:"$1 " [AUR] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif command -v paru &>/dev/null; then (timeout 20 paru -Ss "$QUERY" | grep "^aur" | awk '{print "PARU:"$1 " [AUR] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        fi
    fi
    if [ "$REPO_FLATPAK" == "on" ]; then (timeout 15 flatpak search "$QUERY" --columns=application | awk '{print "FLAT:"$1 " [Flatpak] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"; fi
    if [ "$REPO_SNAP" == "on" ]; then (timeout 15 snap find "$QUERY" | awk 'NR>1 {print "SNAP:"$1 " [Snap] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"; fi
    if [ "$REPO_NIX" == "on" ]; then
        if command -v nix-env &>/dev/null; then (timeout 25 nix-env -qaP ".*$QUERY.*" 2>/dev/null | head -n 15 | awk '{print "NIX:"$1 " [Nix] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        elif [ -f "/nix/var/nix/profiles/default/bin/nix-env" ]; then (timeout 25 /nix/var/nix/profiles/default/bin/nix-env -qaP ".*$QUERY.*" 2>/dev/null | head -n 15 | awk '{print "NIX:"$1 " [Nix] OFF"}' >> $RES_FILE) & PIDS="$PIDS $!"
        fi
    fi
    wait $PIDS
    if [ ! -s $RES_FILE ]; then dialog --msgbox "Nenhum pacote encontrado." 6 40; return; fi

    OPTIONS=()
    while read -r line; do
        TAG=$(echo "$line" | awk '{print $1}')
        ITEM=$(echo "$line" | cut -d' ' -f2-)
        STAT=$(echo "$ITEM" | awk '{print $NF}')
        DESC=$(echo "$ITEM" | sed "s/ $STAT$//")
        OPTIONS+=("$TAG" "$DESC" "$STAT")
    done < <(sort "$RES_FILE" | uniq)

    SELECTED=$(dialog --stdout --title "Resultados: $QUERY" \
        --checklist "[ESPAÇO] Selecionar | [ENTER] Instalar" 22 80 12 "${OPTIONS[@]}")
    
    if [ $? -eq 0 ] && [ ! -z "$SELECTED" ]; then
        clear
        for item in $SELECTED; do
            item=$(echo "$item" | sed 's/"//g')
            
            # --- PROTEÇÃO CONTRA ERRO DE BUSCA ---
            if [[ "$item" != *":"* ]]; then
                echo "Ignorando entrada inválida: $item"
                continue
            fi
            # -------------------------------------

            TYPE=$(echo "$item" | cut -d':' -f1); PKG=$(echo "$item" | cut -d':' -f2)
            echo "--- Instalando $PKG ---"
            case $TYPE in 
                DNF) sudo dnf install -y "$PKG" ;; 
                PAC) CLEAN=$(echo "$PKG"|cut -d'/' -f2); sudo pacman -S --noconfirm --needed "$CLEAN" ;; 
                YAY) CLEAN=$(echo "$PKG"|cut -d'/' -f2); yay -S --needed --noconfirm "$CLEAN" ;; 
                APT) sudo apt install -y "$PKG" ;; 
                FLAT) flatpak install -y "$PKG" ;; 
                SNAP) sudo snap install "$PKG" ;; 
                NIX) if command -v nix-env &>/dev/null; then nix-env -iA "$PKG"; else $HOME/.nix-profile/bin/nix-env -iA "$PKG"; fi ;; 
            esac
        done
        read -p "Concluído. Enter..."
    fi
}
omni_menu() {
    while true; do OPT=$(dialog --stdout --title "Omni-Installer" --menu "Opções" 20 70 10 "1" "   $I_SRC  Buscar e Instalar" "2" "   $I_CFG  Configurar Repositórios" "3" "   $I_EXT  Voltar"); [ -z "$OPT" ] && break; case $OPT in 1) omni_search ;; 2) configure_repos ;; 3) break ;; esac; done
}

# ==========================================
# 2. SYSADMIN TOOLS
# ==========================================
open_nwg_look() {
    if ! command -v nwg-look &>/dev/null; then
        if dialog --stdout --yesno "nwg-look não instalado. Instalar?" 6 40; then
            clear; if command -v pacman &>/dev/null; then sudo pacman -S --noconfirm nwg-look; elif command -v yay &>/dev/null; then yay -S nwg-look; else dialog --msgbox "Instale manualmente." 6 30; return; fi
        else return; fi
    fi
    nwg-look &
}
install_icons_tar() {
    FILE=$(dialog --stdout --title "Selecione o arquivo .tar" --fselect "$HOME/Downloads/" 10 70); [ -z "$FILE" ] && return
    if [[ "$FILE" != *.tar* ]]; then dialog --msgbox "Arquivo inválido." 6 40; return; fi
    DEST="$HOME/.local/share/icons"; mkdir -p "$DEST"
    tar -xf "$FILE" -C "$DEST"; dialog --msgbox "Instalado em $DEST" 6 30
}
network_tools() {
    while true; do OPT=$(dialog --stdout --menu "Rede" 20 70 10 "1" "   $I_NET  Scanner de Rede" "2" "   $I_CFG  Firewall (IPTables)" "3" "   $I_EXT  Voltar"); [ -z "$OPT" ] && break
    case $OPT in 1) sudo arp-scan --localnet --ignoredups --retry=2 > /tmp/s; opts=(); while read l; do ip=$(echo "$l"|grep -oP '^\d{1,3}(\.\d{1,3}){3}'); [ ! -z "$ip" ] && opts+=("$ip" "Dev"); done < /tmp/s; sel=$(dialog --stdout --menu "IPs:" 20 70 10 "${opts[@]}"); [ ! -z "$sel" ] && sudo nmap -F "$sel" | dialog --programbox 20 70 ;; 2) sudo iptables -L INPUT -n > /tmp/f; dialog --textbox /tmp/f 20 80 ;; 3) break ;; esac; done
}
docker_tools() {
    [ ! -x "$(command -v docker)" ] && return; while true; do containers=$(docker ps -a --format "{{.ID}}:{{.Names}} ({{.Status}})"|awk -F: '{printf "%s \"%s\" ", $1, $2}'); [ -z "$containers" ] && { dialog --msgbox "Zero containers." 6 30; return; }; CID=$(eval dialog --stdout --menu \"Containers:\" 20 70 10 $containers); [ -z "$CID" ] && break; ACT=$(dialog --stdout --menu "Ação:" 15 50 4 "start" "Start" "stop" "Stop" "restart" "Restart" "logs" "Logs"); [ -z "$ACT" ] && continue; case $ACT in logs) docker logs "$CID"|tail -n 50 > /tmp/l; dialog --textbox /tmp/l 20 80 ;; *) clear; sudo docker "$ACT" "$CID"; sleep 1 ;; esac; done
}
disk_tools() {
    while true; do OPT=$(dialog --stdout --menu "Disco" 20 70 10 "1" "   $I_DSK  Uso Geral" "2" "   $I_CFG  Tamanho Pastas" "3" "   $I_EXT  Voltar"); [ -z "$OPT" ] && break
    case $OPT in 1) df -h|grep -v "loop" > /tmp/d; dialog --textbox /tmp/d 20 80 ;; 2) du -h --max-depth=1 "$HOME" 2>/dev/null|sort -rh|head -20 > /tmp/d; dialog --textbox /tmp/d 20 80 ;; 3) break ;; esac; done
}
sysadmin_manager() {
    while true; do OPT=$(dialog --stdout --title "SysAdmin" --menu "Ferramentas" 20 70 12 "1" "   $I_THE  Gerenciador de Temas" "2" "   $I_PKG  Instalar Ícones (.tar)" "3" "   $I_NET  Rede" "4" "   $I_DOC  Docker" "5" "   $I_DSK  Disco" "6" "   $I_CFG  Serviços" "7" "   $I_PKG  Atualizar Sistema" "8" "   $I_EXT  Voltar"); [ -z "$OPT" ] && break
    case $OPT in 1) open_nwg_look ;; 2) install_icons_tar ;; 3) network_tools ;; 4) docker_tools ;; 5) disk_tools ;; 6) s=$(dialog --stdout --inputbox "Serviço:" 10 40); [ ! -z "$s" ] && { clear; sudo systemctl status "$s"; read -p "Enter..."; } ;; 7) clear; command -v pacman &>/dev/null && sudo pacman -Syu || sudo dnf update; read -p "Enter..." ;; 8) return ;; esac; done
}

# ==========================================
# 3. SPICETIFY
# ==========================================
spicetify_tools() {
    while true; do OPT=$(dialog --stdout --menu "Spicetify" 20 70 10 "1" "   $I_PKG  Instalar Spicetify" "2" "   $I_PKG  Instalar Marketplace" "3" "   $I_CFG  Fix Permissões Flatpak" "4" "   $I_THE  Instalar Tema Catppuccin" "5" "   $I_CFG  Aplicar Alterações" "6" "   $I_EXT  Voltar"); [ -z "$OPT" ] && break
    case $OPT in 1) clear; curl -fsSL https://spicetify.app/install.sh | sh; export PATH=$PATH:$HOME/.spicetify; read -p "OK..." ;; 2) clear; curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh; read -p "OK..." ;; 3) clear; sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/ -R; read -p "OK..." ;; 4) clear; d="$(dirname "$(spicetify -c)")/Themes"; mkdir -p "$d"; cd "$d"; git clone https://github.com/catppuccin/spicetify.git catppuccin 2>/dev/null; cp -r catppuccin/* .; spicetify config current_theme catppuccin color_scheme mocha; read -p "OK..." ;; 5) clear; spicetify restore backup apply; read -p "OK..." ;; 6) break ;; esac; done
}

# ==========================================
# 4. WM MANAGER
# ==========================================

hyprland_tools() {
    [ ! -f "$HYPR_USER" ] && { dialog --msgbox "Config não achada: $HYPR_USER" 6 40; return; }
    while true; do
        OPT=$(dialog --stdout --menu "Hyprland Manager" 20 70 10 "1" "   $I_CFG  Novo Bind" "2" "   $I_CLN  Apagar Bind" "3" "   $I_DSK  Listar Binds" "4" "   $I_CFG  Editar Sistema" "5" "   $I_PKG  Restaurar Backup" "6" "   $I_CFG  Recarregar" "7" "   $I_EXT  Voltar")
        [ -z "$OPT" ] && break
        case $OPT in
            1)
                MODS=$(dialog --stdout --checklist "Modificadores:" 15 50 5 "\$mainMod" "Super" ON "SHIFT" "Shift" OFF "CTRL" "Ctrl" OFF "ALT" "Alt" OFF)
                MODS_CLEAN=$(echo $MODS | sed 's/"//g'); [ -z "$MODS_CLEAN" ] && continue
                KEY=$(dialog --stdout --inputbox "Tecla:" 10 40); [ -z "$KEY" ] && continue
                CMD=$(dialog --stdout --inputbox "Comando:" 10 40); [ -z "$CMD" ] && continue
                DESC=$(dialog --stdout --inputbox "Descrição:" 10 40); [ -z "$DESC" ] && DESC="Custom"
                if dialog --stdout --yesno "Rodar no terminal?" 8 60; then CMD="kitty -e $CMD"; fi
                mkdir -p "$HYPR_BACKUP"; cp "$HYPR_USER" "$HYPR_BACKUP/bkp_$(date +%s).conf"
                echo "" >> "$HYPR_USER"; echo "bind = $MODS_CLEAN, $KEY, exec, $CMD #\"$DESC\"" >> "$HYPR_USER"
                dialog --msgbox "Salvo!" 6 20 ;;
            2) grep -n "^bind =" "$HYPR_USER" > /tmp/br; opts=(); while read l; do ln=$(echo "$l"|cut -d: -f1); tx=$(echo "$l"|cut -d: -f2-|cut -c 1-45); opts+=("$ln" "$tx"); done < /tmp/br; rm /tmp/br; [ ${#opts[@]} -eq 0 ] && continue; del=$(dialog --stdout --menu "Apagar:" 20 75 10 "${opts[@]}"); [ ! -z "$del" ] && sed -i "${del}d" "$HYPR_USER" ;;
            3) grep "bind =" "$HYPR_USER" > /tmp/b; dialog --textbox /tmp/b 20 80 ;;
            4) [ -f "$HYPR_SYS" ] && { command -v micro &>/dev/null && EDITOR="micro" || EDITOR="nano"; $EDITOR "$HYPR_SYS"; } || dialog --msgbox "Arquivo não existe." 6 30 ;;
            5) bk=$(ls "$HYPR_BACKUP"|sort -r|head -10|while read l; do echo "$l" "$l"; done|xargs dialog --stdout --menu "Restore:" 15 60 5); [ ! -z "$bk" ] && cp "$HYPR_BACKUP/$bk" "$HYPR_USER" ;;
            6) hyprctl reload ;;
            7) break ;;
        esac
    done
}

niri_tools() {
    if [ ! -f "$NIRI_USER" ]; then mkdir -p "$(dirname "$NIRI_USER")"; touch "$NIRI_USER"; fi
    while true; do
        OPT=$(dialog --stdout --menu "Niri Manager (KDL)" 20 70 10 "1" "   $I_CFG  Novo Bind" "2" "   $I_DSK  Listar Binds" "3" "   $I_CFG  Editar Manual" "4" "   $I_EXT  Voltar")
        [ -z "$OPT" ] && break
        case $OPT in
            1)
                MODS=$(dialog --stdout --checklist "Modificadores:" 15 50 5 "Mod" "Super/Win" ON "Shift" "Shift" OFF "Ctrl" "Ctrl" OFF "Alt" "Alt" OFF)
                MODS_CLEAN=$(echo $MODS | sed 's/"//g' | tr ' ' '+'); [ -z "$MODS_CLEAN" ] && continue
                KEY=$(dialog --stdout --inputbox "Tecla:" 10 40); [ -z "$KEY" ] && continue
                CMD=$(dialog --stdout --inputbox "Comando (Spawn):" 10 40); [ -z "$CMD" ] && continue
                FINAL_BIND="bind \"$MODS_CLEAN+$KEY\" { spawn \"$CMD\"; }"
                mkdir -p "$NIRI_BACKUP"; cp "$NIRI_USER" "$NIRI_BACKUP/bkp_$(date +%s).kdl"
                echo "$FINAL_BIND" >> "$NIRI_USER"
                dialog --msgbox "Adicionado:\n$FINAL_BIND" 8 60 ;;
            2) cat "$NIRI_USER" > /tmp/b; dialog --textbox /tmp/b 20 80 ;;
            3) command -v micro &>/dev/null && EDITOR="micro" || EDITOR="nano"; $EDITOR "$NIRI_USER" ;;
            4) break ;;
        esac
    done
}

compositor_select() {
    if [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]; then hyprland_tools
    elif [ "$XDG_CURRENT_DESKTOP" == "Niri" ]; then niri_tools
    else
        SEL=$(dialog --stdout --menu "Qual Compositor?" 15 50 2 "1" "$I_WIN  Hyprland" "2" "$I_WIN  Niri")
        [ "$SEL" == "1" ] && hyprland_tools
        [ "$SEL" == "2" ] && niri_tools
    fi
}

# --- MENU PRINCIPAL ---
while true; do
    MAIN=$(dialog --stdout --title "Master Panel v12.1" --menu "Painel de Controle" 20 70 10 \
    "1" "   $I_PKG  Omni-Installer" \
    "2" "   $I_SYS  SysAdmin" \
    "3" "   $I_SPT  Spicetify" \
    "4" "   $I_WIN  WM Manager" \
    "5" "   $I_CLN  Limpeza" \
    "6" "   $I_EXT  Sair")
    [ -z "$MAIN" ] && break
    case $MAIN in
        1) omni_menu ;; 2) sysadmin_manager ;; 3) spicetify_tools ;; 4) compositor_select ;; 
        5) clear; flatpak uninstall --unused; rm -rf ~/.cache/thumbnails/*; dialog --msgbox "Sistema Limpo!" 6 30 ;; 
        6) break ;;
    esac
done
clear; rm /tmp/.dialogrc_catppuccin
