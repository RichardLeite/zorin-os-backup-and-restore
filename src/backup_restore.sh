#!/bin/bash

CONFIG_FILE=".conf"

# Function to create directories
create_directory() {
    local dir="$1"
    mkdir -p "$dir"
}

# Function to compress files
compress_files() {
    local source="$1"
    local destination="$2"
    tar -cJf "$destination" -C "$(dirname "$source")" "$(basename "$source")"
}

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to install Zsh if not installed
install_zsh() {
    if ! command -v zsh &> /dev/null; then
        log_message "Zsh não encontrado. Instalando Zsh..."
        # Script de instalação do Zsh do GitHub
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        log_message "Zsh instalado com sucesso."
    else
        log_message "Zsh já está instalado."
    fi
}

# Function to configure backup directories
configure_backup_dirs() {
    log_message "Iniciando configuração do diretório de backup."
    echo "Configuração do Diretório de Backup:"
    echo "1) Padrão (pasta atual)"
    echo "2) Personalizado"
    read -p "Escolha uma opção (1-2): " backup_opcao

    case $backup_opcao in
        1) backup_path="$(pwd)/backup/" ;;
        2) read -p "Digite o caminho completo para o diretório de backup: " backup_path ;;
        *) echo "Opção inválida. Usando diretório padrão."; backup_path="$(pwd)/backup/" ;;
    esac

    create_directory "$backup_path"
    echo "BACKUP_DIR=$backup_path" >> "$CONFIG_FILE"
    log_message "Diretório de backup configurado: $backup_path"
}

# Function to configure backup items
configure_backup_items() {
    log_message "Iniciando configuração dos itens para backup."
    echo "Configuração dos Itens para Backup:"
    echo "1) Todos os itens"
    echo "2) Personalizar"
    read -p "Escolha uma opção (1-2): " backup_items_option

    case $backup_items_option in
        1)
            include_dotfiles="y"
            include_config="y" 
            include_powerlevel="y"
            include_apt="y"
            include_snap_flatpak="y"
            include_themes="y"
            include_fonts="y"
            include_extensions="y"
            include_zsh_plugins="y"
            ;;
        2)
            echo "Selecione os itens que deseja incluir no backup (y/n para cada opção)"
            read -p "Dotfiles (.zshrc, .bashrc)? " include_dotfiles
            read -p "Configurações (.config)? " include_config
            read -p "Tema Powerlevel10k? " include_powerlevel
            read -p "Lista de pacotes (APT)? " include_apt
            read -p "Lista de pacotes Snap e Flatpak? " include_snap_flatpak
            read -p "Temas e ícones do sistema? " include_themes
            read -p "Fontes personalizadas? " include_fonts
            read -p "Extensões GNOME? " include_extensions
            read -p "Plugins do Zsh? " include_zsh_plugins
            ;;
        *)
            echo "Opção inválida. Usando todos os itens."
            include_dotfiles="y"
            include_config="y"
            include_powerlevel="y"
            include_apt="y"
            include_snap_flatpak="y"
            include_themes="y"
            include_fonts="y"
            include_extensions="y"
            include_zsh_plugins="y"
            ;;
    esac

    # Salvando configurações de backup
    echo "INCLUDE_DOTFILES=${include_dotfiles,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_CONFIG=${include_config,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_POWERLEVEL=${include_powerlevel,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_APT=${include_apt,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_SNAP_FLATPAK=${include_snap_flatpak,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_THEMES=${include_themes,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_FONTS=${include_fonts,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_EXTENSIONS=${include_extensions,,}" >> "$CONFIG_FILE"
    echo "INCLUDE_ZSH_PLUGINS=${include_zsh_plugins,,}" >> "$CONFIG_FILE"

    log_message "Configurações de itens para backup salvas com sucesso!"
}

# Function to configure restore directories
configure_restore_dirs() {
    log_message "Iniciando configuração do diretório de restauração."
    echo "Configuração do Diretório de Restauração:"
    echo "1) Padrão (pasta atual)"
    echo "2) Personalizado"
    read -p "Escolha uma opção (1-2): " restore_opcao

    case $restore_opcao in
        1) restore_path="$(pwd)/backup" ;;
        2) read -p "Digite o caminho completo da pasta onde está o arquivo backup.tar.xz: " restore_path ;;
        *) echo "Opção inválida. Usando diretório padrão."; restore_path="$(pwd)/backup" ;;
    esac

    create_directory "$restore_path"
    echo "RESTORE_DIR=$restore_path" >> "$CONFIG_FILE"
    log_message "Diretório de restauração configurado: $restore_path"
}

# Function to configure restore items
configure_restore_items() {
    log_message "Iniciando configuração dos itens para restauração."
    echo "Configuração dos Itens para Restauração:"
    echo "1) Todos os itens"
    echo "2) Personalizar"
    read -p "Escolha uma opção (1-2): " restore_items_option

    case $restore_items_option in
        1)
            restore_dotfiles="y"
            restore_config="y"
            restore_powerlevel="y"
            restore_themes="y"
            restore_fonts="y"
            restore_extensions="y"
            restore_zsh_plugins="y"
            ;;
        2)
            echo "Selecione os itens que deseja permitir restaurar (y/n para cada opção)"
            read -p "Dotfiles (.zshrc, .bashrc)? " restore_dotfiles
            read -p "Configurações (.config)? " restore_config
            read -p "Tema Powerlevel10k? " restore_powerlevel
            read -p "Temas e ícones do sistema? " restore_themes
            read -p "Fontes personalizadas? " restore_fonts
            read -p "Extensões GNOME? " restore_extensions
            read -p "Plugins do Zsh? " restore_zsh_plugins
            ;;
        *)
            echo "Opção inválida. Usando todos os itens."
            restore_dotfiles="y"
            restore_config="y"
            restore_powerlevel="y"
            restore_themes="y"
            restore_fonts="y"
            restore_extensions="y"
            restore_zsh_plugins="y"
            ;;
    esac

    # Salvando configurações de restauração
    echo "RESTORE_DOTFILES=${restore_dotfiles,,}" >> "$CONFIG_FILE"
    echo "RESTORE_CONFIG=${restore_config,,}" >> "$CONFIG_FILE"
    echo "RESTORE_POWERLEVEL=${restore_powerlevel,,}" >> "$CONFIG_FILE"
    echo "RESTORE_THEMES=${restore_themes,,}" >> "$CONFIG_FILE"
    echo "RESTORE_FONTS=${restore_fonts,,}" >> "$CONFIG_FILE"
    echo "RESTORE_EXTENSIONS=${restore_extensions,,}" >> "$CONFIG_FILE"
    echo "RESTORE_ZSH_PLUGINS=${restore_zsh_plugins,,}" >> "$CONFIG_FILE"

    log_message "Configurações de itens para restauração salvas com sucesso!"
}

# Function to load configurations
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        log_message "Configuração não encontrada! Iniciando configuração."
        configure_backup_dirs
        configure_backup_items
        configure_restore_dirs
        configure_restore_items
    fi
}

# Function to perform backup
backup() {
    log_message "Iniciando backup..."
    echo
    echo "Iniciando backup..."
    echo "==================="

    TEMP_DIR="$BACKUP_DIR/tempfiles"
    TEMP_TAR_DIR="$BACKUP_DIR/tempTarXz"

    mkdir -p "$BACKUP_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$TEMP_TAR_DIR"

    # Function to compress files
    compress_files() {
        local source="$1"
        local destination="$2"
        local name="$3"
        mkdir -p "$TEMP_DIR/$name"
        cp -r "$source" "$TEMP_DIR/$name"
        tar -cJf "$TEMP_TAR_DIR/$name.tar.xz" -C "$TEMP_DIR" "$name"
        rm -rf "$TEMP_DIR/$name"
    }

    if [ "${INCLUDE_DOTFILES}" = "y" ]; then
        echo "Compactando dotfiles..."
        compress_files "~/.zshrc" "$TEMP_DIR/dotfiles" "dotfiles"
        compress_files "~/.bashrc" "$TEMP_DIR/dotfiles" "dotfiles"
    fi

    if [ "${INCLUDE_CONFIG}" = "y" ]; then
        echo "Compactando .config..."
        compress_files "$HOME/.config" "$TEMP_DIR/.config" ".config"
    fi

    if [ "${INCLUDE_POWERLEVEL}" = "y" ]; then
        echo "Compactando tema Powerlevel10k..."
        compress_files "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "$TEMP_DIR/powerlevel10k" "powerlevel10k"
    fi

    if [ "${INCLUDE_ZSH_PLUGINS}" = "y" ]; then
        echo "Compactando plugins do Zsh..."
        compress_files "$HOME/.oh-my-zsh/plugins" "$TEMP_DIR/zsh-plugins" "zsh-plugins"
    fi

    if [ "${INCLUDE_APT}" = "y" ]; then
        echo "Salvando lista de pacotes APT..."
        dpkg --get-selections > "$TEMP_TAR_DIR/packages-list.txt"
    fi

    if [ "${INCLUDE_SNAP_FLATPAK}" = "y" ]; then
        echo "Salvando lista de pacotes Snap e Flatpak..."
        snap list > "$TEMP_TAR_DIR/snap-list.txt"
        flatpak list | grep -v "org.gtk.Gtk3theme.Zorin" > "$TEMP_TAR_DIR/flatpak-list.txt"
    fi

    if [ "${INCLUDE_THEMES}" = "y" ]; then
        echo "Compactando temas e ícones..."
        compress_files "/usr/share/themes" "$TEMP_DIR/themes" "themes"
        compress_files "/usr/share/icons" "$TEMP_DIR/icons" "icons"
    fi

    if [ "${INCLUDE_FONTS}" = "y" ]; then
        echo "Compactando fontes..."
        compress_files "$HOME/.local/share/fonts" "$TEMP_DIR/fonts" "fonts"
    fi

    if [ "${INCLUDE_EXTENSIONS}" = "y" ]; then
        echo "Compactando extensões GNOME..."
        compress_files "$HOME/.local/share/gnome-shell/extensions" "$TEMP_DIR/gnome-extensions-user" "gnome-extensions-user"
        echo "Salvando configurações do GNOME Extensions..."
        dconf dump /org/gnome/shell/extensions/ > "$TEMP_TAR_DIR/gnome-extensions-settings.dconf"
    fi

    cd "$TEMP_TAR_DIR" && tar -cJf "$BACKUP_DIR/backup.tar.xz" *

    rm -rf "$TEMP_DIR"
    rm -rf "$TEMP_TAR_DIR"
    
    log_message "Backup concluído! Arquivos salvos e compactados em backup.tar.xz"
}

# Function to restore files
restore() {
    log_message "Iniciando restauração..."
    echo "Iniciando restauração..."
    echo "========================"

    # Instalar Zsh antes de restaurar
    install_zsh

    if [ ! -f "$RESTORE_DIR/backup.tar.xz" ]; then
        echo "Arquivo backup.tar.xz não encontrado em: $RESTORE_DIR"
        return 1
    fi

    TEMP_RESTORE_DIR="$RESTORE_DIR/temp_restore"
    create_directory "$TEMP_RESTORE_DIR"

    # Extrair o backup
    echo "Extraindo arquivos do backup..."
    cd "$TEMP_RESTORE_DIR" && tar -xJf "$RESTORE_DIR/backup.tar.xz"

    # Função para restaurar arquivos
    restore_files() {
        local source="$1"
        local destination="$2"
        cp -r "$source" "$destination"
    }

    if [ "${RESTORE_DOTFILES}" = "y" ]; then
        echo "Restaurando dotfiles..."
        restore_files "$TEMP_RESTORE_DIR/dotfiles/.zshrc" ~/
        restore_files "$TEMP_RESTORE_DIR/dotfiles/.bashrc" ~/
    fi

    if [ "${RESTORE_CONFIG}" = "y" ]; then
        echo "Restaurando .config..."
        restore_files "$TEMP_RESTORE_DIR/.config/." "$HOME/.config"
    fi

    if [ "${RESTORE_POWERLEVEL}" = "y" ]; then
        echo "Restaurando tema Powerlevel10k..."
        restore_files "$TEMP_RESTORE_DIR/powerlevel10k/." "$HOME/.oh-my-zsh/custom/themes/"
    fi

    if [ "${RESTORE_ZSH_PLUGINS}" = "y" ]; then
        echo "Restaurando plugins do Zsh..."
        restore_files "$TEMP_RESTORE_DIR/zsh-plugins/." "$HOME/.oh-my-zsh/plugins/"
    fi

    if [ "${RESTORE_THEMES}" = "y" ]; then
        echo "Restaurando temas e ícones..."
        restore_files "$TEMP_RESTORE_DIR/themes/." /usr/share/themes/
        restore_files "$TEMP_RESTORE_DIR/icons/." /usr/share/icons/
    fi

    if [ "${RESTORE_FONTS}" = "y" ]; then
        echo "Restaurando fontes..."
        restore_files "$TEMP_RESTORE_DIR/fonts/." "$HOME/.local/share/fonts/"
    fi

    if [ "${RESTORE_EXTENSIONS}" = "y" ]; then
        echo "Restaurando extensões GNOME..."
        restore_files "$TEMP_RESTORE_DIR/gnome-extensions-user/." "$HOME/.local/share/gnome-shell/extensions/"
        echo "Restaurando configurações do GNOME Extensions..."
        dconf load /org/gnome/shell/extensions/ < "$TEMP_RESTORE_DIR/gnome-extensions-settings.dconf"
    fi

    # Limpeza
    rm -rf "$TEMP_RESTORE_DIR"

    log_message "Restauração concluída!"
}

# Função principal
main() {
    load_config

    while true; do
        echo "Bem-vindo ao Zorin OS Backup & Restore"
        echo "======================================"

        PS3="Selecione uma opção: "
        options=("Configuração" "Backup" "Restore" "Sair")

        select opt in "${options[@]}"; do
            case $opt in
                "Configuração") configure_options; break ;;
                "Backup") backup; exit 0 ;;
                "Restore") restore; exit 0 ;;
                "Sair") log_message "Programa finalizado."; exit 0 ;;
                *) echo "Opção inválida. Selecione um número entre 1-4"; ;;
            esac
        done
    done
}

main