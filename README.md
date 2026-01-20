# 🎛️ Master Control Panel (Hyprland & Niri Edition)

Um painel de controle TUI (Terminal User Interface) completo para gerenciar sistemas **Arch Linux**. Projetado originalmente para Hyprland, agora com **suporte total ao Niri Compositor**.

Este script unifica o gerenciamento de pacotes, administração do sistema, personalização de temas (ícones/GTK) e configuração de atalhos (Keybinds) em uma interface visual elegante.

---

## ✨ Funcionalidades

### 📦 1. Omni-Installer (Multi-Select)

Busca e instala pacotes em múltiplos repositórios simultaneamente.

* **Interface:** Checklist (Use `Espaço` para selecionar vários, `Enter` para instalar).
* **Fontes Suportadas:**
* 📦 **Nativo:** Pacman (Arch), DNF (Fedora), Apt (Debian).
* 🦄 **AUR:** Yay ou Paru.
* 📦 **Flatpak:** Flathub.
* 🛍️ **Snap:** Snapcraft.
* ❄️ **Nix:** Nixpkgs (com detecção automática).


* **Smart Skip:** Pula automaticamente pacotes que já estão instalados para economizar tempo.

### 🛠️ 2. SysAdmin & Temas

Ferramentas essenciais para manutenção e estética.

* **🎨 Gerenciador de Temas:**
* **Instalador Universal de Ícones:** Extrai `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2` direto para `~/.local/share/icons`.
* **nwg-look:** Atalho rápido para a interface de temas GTK.
* **Fix de Ícones:** Força variáveis de ambiente (`QT_QPA_PLATFORMTHEME`) para corrigir ícones sumindo em apps no Wayland.


* **🔧 Ferramentas de Sistema:**
* **Rede:** Scanner de IP (`arp-scan`) e Portas (`nmap`).
* **Docker:** Gerenciamento visual de containers (Start, Stop, Logs).
* **Disco:** Análise visual com `ncdu` ou estatísticas rápidas.
* **Monitor:** Acesso rápido ao `btop`.



### 🎵 3. Spicetify Tools

Gerencie seu cliente Spotify modificado.

* Instalação automática do Spicetify CLI e Marketplace.
* Correção de permissões para versão Flatpak.
* Aplicação automática do tema **Catppuccin Mocha**.

###  4. WM Manager (Hyprland & Niri)

Detecta automaticamente seu ambiente (`$XDG_CURRENT_DESKTOP`) e abre o gerenciador correto.

* **Hyprland Manager:**
* Adiciona atalhos (`bind`) compatíveis com plugins como *Noctalia Keybind Cheatsheet*.
* Detecta comandos de terminal e adiciona o wrapper (ex: `kitty -e htop`).
* Edita `UserKeybinds.conf`.


* **Niri Manager (NOVO):**
* Cria atalhos no formato **KDL** específico do Niri.
* Sintaxe correta: `bind "Mod+T" { spawn "kitty"; }`.
* Gerencia um arquivo separado `UserKeybinds.kdl` para manter seu `config.kdl` limpo.
* Recarrega a configuração instantaneamente (`niri msg action reload-config`).



---

## 🚀 Instalação

1. **Baixe o script:**
Salve o arquivo `master_panel_v12.1.sh`.
2. **Dê permissão de execução:**
```bash
chmod +x master_panel_v12.1.sh

```


3. **Execute:**
```bash
./master_panel_v12.1.sh

```



*Nota: O script instalará automaticamente dependências como `dialog`, `btop`, `arp-scan` se faltarem.*

---

## ⚙️ Configuração dos Arquivos

O script organiza suas configurações customizadas em arquivos separados para evitar que atualizações do sistema sobrescrevam suas mudanças.

### 🔷 Para Usuários Hyprland

Adicione isto ao topo do seu `hyprland.conf`:

```ini
source = ~/.config/hypr/UserConfigs/UserKeybinds.conf

```

### 🔶 Para Usuários Niri

Adicione isto ao seu `~/.config/niri/config.kdl` (dentro ou fora do bloco principal, dependendo da versão):

```kdl
include "./UserConfigs/UserKeybinds.kdl"

```

*O script cria o arquivo e a pasta automaticamente na primeira execução.*

---

## 📸 Estrutura do Menu

```text
Menu Principal
├──  Omni-Installer
│   ├── Seleção Multipla de Pacotes (Checklist)
│   └── Configurar Repositórios
├──  SysAdmin & Temas
│   ├──  FIX: Ícones Sumindo (Env Variables)
│   ├──  Abrir nwg-look
│   ├──  Instalar Ícones (Tarball Extractor)
│   ├──  Rede /  Docker /  Disco
│   └──  Atualizar Sistema
├──  Spicetify Tools
│   └── Instalar / Marketplace / Temas
└──  WM Manager (Auto-Detect)
    ├── Hyprland: Edita .conf, Reload via hyprctl
    └── Niri: Edita .kdl, Reload via niri msg

```

---

## 📝 Requisitos

* **Distro:** Arch Linux (Recomendado), Fedora, Debian.
* **Dependências Core:** `dialog`, `curl`, `tar`, `sed`, `grep`.
* **Fontes:** Requer uma **Nerd Font** instalada no terminal para visualizar os ícones corretamente.

---

## 🤝 Créditos

Desenvolvido para facilitar a vida de usuários de Tiling Window Managers que preferem uma interface rápida e unificada a editar dezenas de arquivos de texto manualmente.
