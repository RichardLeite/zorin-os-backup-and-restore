#!/bin/bash

CONFIG_FILE=".conf"

configure_dirs() {
    echo
    echo "Configuração dos Diretórios"
    echo "=========================="
    
    echo "Configuração do Diretório de Backup:"
    echo "1) Padrão (pasta atual)"
    echo "2) Personalizado"
    read -p "Escolha uma opção (1-2): " backup_opcao

    case $backup_opcao in
        1)
            backup_path="$(pwd)"
            ;;
        2)
            read -p "Digite o caminho completo para o diretório de backup: " backup_path
            ;;
        *)
            echo "Opção inválida. Usando diretório padrão."
            backup_path="$(pwd)"
            ;;
    esac

    echo
    echo "Configuração do Diretório de Restauração:"
    echo "1) Padrão (pasta atual)"
    echo "2) Personalizado"
    read -p "Escolha uma opção (1-2): " restore_opcao

    case $restore_opcao in
        1)
            restore_path="$(pwd)"
            ;;
        2)
            read -p "Digite o caminho completo onde está o arquivo backup.tar.xz: " restore_path
            ;;
        *)
            echo "Opção inválida. Usando diretório padrão."
            restore_path="$(pwd)"
            ;;
    esac

    mkdir -p "$backup_path/backup"
    
    echo "BACKUP_DIR=$backup_path/backup" > "$CONFIG_FILE"
    echo "RESTORE_DIR=$restore_path" >> "$CONFIG_FILE"
    
    echo
    echo "Configurações salvas com sucesso!"
    echo "Diretório de backup: $backup_path/backup"
    echo "Diretório de restauração: $restore_path"
    echo
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Configuração não encontrada!"
        configure_dirs
    fi
}

backup() {
    echo
    echo "Iniciando backup..."
    echo "==================="

    TEMP_DIR="$BACKUP_DIR/temp"

    mkdir -p "$BACKUP_DIR"
    mkdir -p "$TEMP_DIR"

    echo "Compactando dotfiles..."
    mkdir -p "$TEMP_DIR/dotfiles"
    cp ~/.zshrc ~/.bashrc "$TEMP_DIR/dotfiles"
    tar -cJf "$BACKUP_DIR/dotfiles.tar.xz" -C "$TEMP_DIR" dotfiles
    rm -rf "$TEMP_DIR/dotfiles"

    echo "Compactando .config..."
    cp -r "$HOME/.config" "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/config.tar.xz" -C "$TEMP_DIR" .config
    rm -rf "$TEMP_DIR/.config"

    echo "Compactando tema Powerlevel10k..."
    cp -r "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/powerlevel10k.tar.xz" -C "$TEMP_DIR" powerlevel10k
    rm -rf "$TEMP_DIR/powerlevel10k"

    echo "Salvando lista de pacotes APT..."
    dpkg --get-selections > "$BACKUP_DIR/packages-list.txt"

    echo "Salvando lista de pacotes Snap e Flatpak..."
    snap list > "$BACKUP_DIR/snap-list.txt"
    flatpak list > "$BACKUP_DIR/flatpak-list.txt"

    echo "Compactando temas, fontes e extensões GNOME..."
    cp -r /usr/share/themes "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/themes.tar.xz" -C "$TEMP_DIR" themes
    rm -rf "$TEMP_DIR/themes"

    cp -r /usr/share/icons "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/icons.tar.xz" -C "$TEMP_DIR" icons
    rm -rf "$TEMP_DIR/icons"

    cp -r "$HOME/.local/share/fonts" "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/fonts.tar.xz" -C "$TEMP_DIR" fonts
    rm -rf "$TEMP_DIR/fonts"

    cp -r "$HOME/.local/share/gnome-shell/extensions" "$TEMP_DIR/gnome-extensions-user"
    tar -cJf "$BACKUP_DIR/gnome-extensions-user.tar.xz" -C "$TEMP_DIR" gnome-extensions-user
    rm -rf "$TEMP_DIR/gnome-extensions-user"

    cp -r /usr/share/gnome-shell/extensions "$TEMP_DIR/gnome-extensions-system"
    tar -cJf "$BACKUP_DIR/gnome-extensions-system.tar.xz" -C "$TEMP_DIR" gnome-extensions-system
    rm -rf "$TEMP_DIR/gnome-extensions-system"

    echo "Salvando configurações do GNOME Extensions..."
    dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions-settings.dconf"

    tar -cJf backup.tar.xz -C "$BACKUP_DIR" .

    rm -rf "$TEMP_DIR"
    rm -rf "$BACKUP_DIR"
    
    echo "Backup concluído! Arquivos salvos e compactados em backup.tar.xz"
}

restore() {
    echo
    echo "Iniciando restauração..."
    echo "========================"

    if [ ! -f "$RESTORE_DIR/backup.tar.xz" ]; then
        echo "Arquivo backup.tar.xz não encontrado em: $RESTORE_DIR"
        return 1
    fi

    TEMP_RESTORE_DIR="./temp_restore"
    mkdir -p "$TEMP_RESTORE_DIR"
    
    tar -xJf "$RESTORE_DIR/backup.tar.xz" -C "$TEMP_RESTORE_DIR"
    
    BACKUP_DIR="$TEMP_RESTORE_DIR"

    echo "Restaurando dotfiles..."
    tar -xJf "$BACKUP_DIR/dotfiles.tar.xz" -C "$HOME"

    echo "Restaurando .config..."
    tar -xJf "$BACKUP_DIR/config.tar.xz" -C "$HOME"

    echo "Restaurando tema Powerlevel10k..."
    mkdir -p ~/.oh-my-zsh/custom/themes
    tar -xJf "$BACKUP_DIR/powerlevel10k.tar.xz" -C ~/.oh-my-zsh/custom/themes

    if [[ -f "$BACKUP_DIR/packages-list.txt" ]]; then
        echo "Restaurando pacotes APT..."
        sudo dpkg --set-selections < "$BACKUP_DIR/packages-list.txt" && sudo apt-get dselect-upgrade
    fi

    if [[ -f "$BACKUP_DIR/snap-list.txt" ]]; then
        echo "Restaurando pacotes Snap..."
        xargs -a "$BACKUP_DIR/snap-list.txt" -I {} sudo snap install {}
    fi
    if [[ -f "$BACKUP_DIR/flatpak-list.txt" ]]; then
        echo "Restaurando pacotes Flatpak..."
        xargs -a "$BACKUP_DIR/flatpak-list.txt" -I {} flatpak install flathub {}
    fi

    echo "Restaurando temas, fontes e extensões GNOME..."
    sudo tar -xJf "$BACKUP_DIR/themes.tar.xz" -C /usr/share
    sudo tar -xJf "$BACKUP_DIR/icons.tar.xz" -C /usr/share
    tar -xJf "$BACKUP_DIR/fonts.tar.xz" -C "$HOME/.local/share"
    tar -xJf "$BACKUP_DIR/gnome-extensions-user.tar.xz" -C "$HOME/.local/share/gnome-shell"
    sudo tar -xJf "$BACKUP_DIR/gnome-extensions-system.tar.xz" -C /usr/share/gnome-shell

    echo "Restaurando configurações do GNOME Extensions..."
    dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions-settings.dconf"

    rm -rf "$TEMP_RESTORE_DIR"
    
    echo "Restauração concluída!"
}

main() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo
        echo "Primeira execução detectada - Configuração inicial necessária"
        echo "========================================================"
        configure_dirs
    fi

    while true; do
        echo
        echo "Bem-vindo ao Zorin OS Backup & Restore"
        echo "======================================"
        echo

        PS3="Selecione uma opção: "
        options=("Configuração" "Backup" "Restore" "Sair")

        select opt in "${options[@]}"
        do
            case $opt in
                "Configuração")
                    configure_dirs
                    break
                    ;;
                "Backup")
                    load_config
                    backup
                    exit 0
                    ;;
                "Restore")
                    load_config
                    restore
                    exit 0
                    ;;
                "Sair")
                    echo "Programa finalizado."
                    exit 0
                    ;;
                *) 
                    echo "Opção inválida. Selecione um número entre 1-4"
                    ;;
            esac
        done
    done
}

main
