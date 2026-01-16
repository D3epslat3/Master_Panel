
# 🎛️ Master Control Panel (Hyprland Edition)

Um painel de controle TUI (Terminal User Interface) tudo-em-um para gerenciar sistemas **Arch Linux com Hyprland** (focado em ambientes como **Noctalia** ou **Hyprdots**).

Este script unifica o gerenciamento de pacotes, administração do sistema, personalização de temas e configuração de atalhos em uma interface visual elegante baseada em `dialog`.

---

## ✨ Funcionalidades

### 📦 1. Omni-Installer (Gerenciador Universal)

Busca e instala pacotes simultaneamente em múltiplos repositórios com uma única pesquisa.

* **Fontes Suportadas:**
* 📦 **Nativo:** Pacman (Arch), DNF (Fedora), Apt (Debian).
* 🦄 **AUR:** Yay ou Paru.
* 📦 **Flatpak:** Flathub.
* 🛍️ **Snap:** Snapcraft.
* ❄️ **Nix:** Nixpkgs (com detecção automática de `nix-env`).


* **Busca Paralela:** Pesquisa em todas as fontes ao mesmo tempo sem travar a interface.

### 🛠️ 2. SysAdmin & Temas

Ferramentas essenciais para manutenção e personalização visual.

* **🎨 Gerenciador de Temas:**
* Instalador automático de ícones via arquivos `.tar`, `.tar.gz`, `.tar.xz`, `.tar.bz2`.
* Atalho rápido para abrir o `nwg-look`.
* **Fix de Ícones:** Força variáveis de ambiente para corrigir ícones sumindo em apps GTK/Noctalia.


* **🔧 Ferramentas de Sistema:**
* **Rede:** Scanner de IP (`arp-scan`) e Portas (`nmap`).
* **Docker:** Gerenciamento visual de containers (Start, Stop, Logs).
* **Disco:** Análise visual de espaço com `ncdu` ou estatísticas rápidas.
* **Monitor:** Acesso rápido ao `btop`.



### 🎵 3. Spicetify Tools

Gerencie seu cliente Spotify modificado.

* Instalação automática do Spicetify CLI.
* Instalação do **Marketplace** (loja de apps).
* Correção de permissões para versão Flatpak.
* Aplicação do tema **Catppuccin**.

### ⌨️ 4. Hyprland Manager (Noctalia Ready)

Gerencie suas keybinds sem editar arquivos manualmente.

* **Plugin Friendly:** Adiciona atalhos no formato específico (`bind = ... #"Descrição"`) para que apareçam no plugin *Keybind Cheatsheet* do Noctalia.
* **Smart Wrapper:** Detecta se o comando é de terminal (ex: `htop`) e adiciona o wrapper do seu terminal padrão automaticamente (ex: `kitty -e htop`).
* **Editor de Sistema:** Atalho para editar o arquivo de binds original do sistema com `micro` ou `nano`.
* **Backups:** Cria backups automáticos antes de qualquer alteração.

---

## 🚀 Instalação

1. **Baixe o script:**
Salve o arquivo `master_panel_v11.3.sh` na sua pasta de preferência.
2. **Dê permissão de execução:**
```bash
chmod +x master_panel_v11.3.sh

```


3. **Execute:**
```bash
./master_panel_v11.3.sh

```



*Nota: O script verificará e instalará automaticamente dependências necessárias como `dialog`, `btop`, `arp-scan`, etc.*

---

## ⚙️ Configuração (Para Usuários Noctalia/Hyprdots)

O script foi otimizado para a estrutura de pastas do **Noctalia/Hyprdots**.

### 1. Caminhos dos Arquivos

O script edita por padrão:

* **Seus Atalhos:** `~/.config/hypr/UserConfigs/UserKeybinds.conf`
* **Variáveis:** `~/.config/hypr/UserConfigs/UserEnvs.conf`

### 2. Configurando o Plugin "Keybind Cheatsheet"

Para ver seus atalhos customizados na barra do Noctalia:

1. Abra o menu de widgets e clique na engrenagem ⚙️ do *Keybind Cheatsheet*.
2. No campo **Hyprland Config**, altere o caminho para:
`/home/SEU_USUARIO/.config/hypr/UserConfigs/UserKeybinds.conf`
3. Clique em **Apply**.

---

## 📸 Estrutura do Menu

```text
Menu Principal
├──  Omni-Installer
│   ├── Configurar Repositórios (Ativar/Desativar Nix, Snap, etc)
│   └── Buscar e Instalar
├──  SysAdmin & Temas
│   ├── 🚑 FIX: Ícones Sumindo (Env Variables)
│   ├── 👔 Abrir nwg-look
│   ├── 📦 Instalar Ícones (Tarball Extractor)
│   ├──  Rede & WiFi
│   └──  Docker / Disco / Serviços
├──  Spicetify Tools
│   ├── Instalar / Marketplace / Permissões
│   └── Aplicar Temas
└──  Hyprland Manager
    ├── Adicionar Bind (Com suporte a descrição)
    ├── Deletar Bind
    ├── Editar Arquivo do Sistema
    └── Restaurar Backup

```

---

## 📝 Requisitos

O script roda na maioria das distros, mas é otimizado para **Arch Linux**.
Dependências (instaladas automaticamente se você usar Pacman):

* `dialog` (Interface)
* `curl`, `tar`, `sed`, `grep` (Core)
* `btop`, `arp-scan`, `nmap` (SysAdmin)
* `nwg-look` (Opcional, para temas)

---
