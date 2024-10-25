#!/bin/bash

# Diretório do backup
BACKUP_DIR="./backup"
TEMP_DIR="$BACKUP_DIR/temp"

# Função de Backup
backup() {
    echo "Iniciando backup..."

    # Cria o diretório de backup e o temporário, se não existirem
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$TEMP_DIR"

    # Backup dos dotfiles
    echo "Compactando dotfiles..."
    mkdir -p "$TEMP_DIR/dotfiles"
    cp ~/.zshrc ~/.bashrc "$TEMP_DIR/dotfiles"
    tar -cJf "$BACKUP_DIR/dotfiles.tar.xz" -C "$TEMP_DIR" dotfiles
    rm -rf "$TEMP_DIR/dotfiles"

    # Backup do diretório .config
    echo "Compactando .config..."
    cp -r "$HOME/.config" "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/config.tar.xz" -C "$TEMP_DIR" .config
    rm -rf "$TEMP_DIR/.config"

    # Backup do Powerlevel10k
    echo "Compactando tema Powerlevel10k..."
    cp -r "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" "$TEMP_DIR"
    tar -cJf "$BACKUP_DIR/powerlevel10k.tar.xz" -C "$TEMP_DIR" powerlevel10k
    rm -rf "$TEMP_DIR/powerlevel10k"

    # Backup da lista de pacotes instalados
    echo "Salvando lista de pacotes APT..."
    dpkg --get-selections > "$BACKUP_DIR/packages-list.txt"

    # Lista de pacotes Snap e Flatpak
    echo "Salvando lista de pacotes Snap e Flatpak..."
    snap list > "$BACKUP_DIR/snap-list.txt"
    flatpak list > "$BACKUP_DIR/flatpak-list.txt"

    # Compactação dos temas, fontes e extensões GNOME
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

    # Backup das configurações do GNOME Extensions no dconf
    echo "Salvando configurações do GNOME Extensions..."
    dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions-settings.dconf"

    # Removendo diretório temporário após o backup
    rm -rf "$TEMP_DIR"
    
    echo "Backup concluído! Arquivos salvos e compactados em $BACKUP_DIR."
}

# Função de Restauração
restore() {
    echo "Iniciando restauração..."

    # Restauração dos dotfiles
    echo "Restaurando dotfiles..."
    tar -xJf "$BACKUP_DIR/dotfiles.tar.xz" -C "$HOME"

    # Restauração do diretório .config
    echo "Restaurando .config..."
    tar -xJf "$BACKUP_DIR/config.tar.xz" -C "$HOME"

    # Restauração do Powerlevel10k
    echo "Restaurando tema Powerlevel10k..."
    mkdir -p ~/.oh-my-zsh/custom/themes
    tar -xJf "$BACKUP_DIR/powerlevel10k.tar.xz" -C ~/.oh-my-zsh/custom/themes

    # Restauração da lista de pacotes APT
    if [[ -f "$BACKUP_DIR/packages-list.txt" ]]; then
        echo "Restaurando pacotes APT..."
        sudo dpkg --set-selections < "$BACKUP_DIR/packages-list.txt" && sudo apt-get dselect-upgrade
    fi

    # Restauração de pacotes Snap e Flatpak
    if [[ -f "$BACKUP_DIR/snap-list.txt" ]]; then
        echo "Restaurando pacotes Snap..."
        xargs -a "$BACKUP_DIR/snap-list.txt" -I {} sudo snap install {}
    fi
    if [[ -f "$BACKUP_DIR/flatpak-list.txt" ]]; then
        echo "Restaurando pacotes Flatpak..."
        xargs -a "$BACKUP_DIR/flatpak-list.txt" -I {} flatpak install flathub {}
    fi

    # Restauração de temas, fontes e extensões GNOME
    echo "Restaurando temas, fontes e extensões GNOME..."
    sudo tar -xJf "$BACKUP_DIR/themes.tar.xz" -C /usr/share
    sudo tar -xJf "$BACKUP_DIR/icons.tar.xz" -C /usr/share
    tar -xJf "$BACKUP_DIR/fonts.tar.xz" -C "$HOME/.local/share"
    tar -xJf "$BACKUP_DIR/gnome-extensions-user.tar.xz" -C "$HOME/.local/share/gnome-shell"
    sudo tar -xJf "$BACKUP_DIR/gnome-extensions-system.tar.xz" -C /usr/share/gnome-shell

    # Restauração das configurações do GNOME Extensions no dconf
    echo "Restaurando configurações do GNOME Extensions..."
    dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/gnome-extensions-settings.dconf"

    echo "Restauração concluída!"
}

# Verificação do modo
if [[ $1 == "backup" ]]; then
    backup
elif [[ $1 == "restore" ]]; then
    restore
else
    echo "Uso: $0 {backup|restore}"
    exit 1
fi
