#!/bin/bash

# Diretório para armazenar o backup
BACKUP_DIR="$HOME/backup_config"

# Função de Backup
backup() {
    echo "Iniciando backup..."

    # Cria diretório de backup, se não existir
    mkdir -p "$BACKUP_DIR"

    # Backup dos dotfiles
    echo "Copiando dotfiles..."
    cp -r ~/.zshrc ~/.bashrc ~/.config "$BACKUP_DIR"
    cp -r ~/.local/share "$BACKUP_DIR"  # Para aplicativos específicos

    # Backup do Powerlevel10k
    echo "Copiando tema Powerlevel10k..."
    cp -r ~/.oh-my-zsh/custom/themes/powerlevel10k "$BACKUP_DIR/powerlevel10k"

    # Lista de pacotes instalados
    echo "Salvando lista de pacotes APT..."
    dpkg --get-selections > "$BACKUP_DIR/packages-list.txt"

    # Lista de pacotes Snap e Flatpak
    echo "Salvando lista de pacotes Snap e Flatpak..."
    snap list > "$BACKUP_DIR/snap-list.txt"
    flatpak list > "$BACKUP_DIR/flatpak-list.txt"

    # Backup de temas, fontes, e extensões GNOME
    echo "Copiando temas, fontes, e extensões GNOME..."
    cp -r /usr/share/themes "$BACKUP_DIR/themes"
    cp -r /usr/share/icons "$BACKUP_DIR/icons"
    cp -r ~/.local/share/fonts "$BACKUP_DIR/fonts"
    cp -r ~/.local/share/gnome-shell/extensions "$BACKUP_DIR/gnome-extensions-user"
    sudo cp -r /usr/share/gnome-shell/extensions "$BACKUP_DIR/gnome-extensions-system"

    # Backup das configurações do GNOME Extensions no dconf
    echo "Salvando configurações do GNOME Extensions..."
    dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/gnome-extensions-settings.dconf"

    echo "Backup concluído! Arquivos salvos em $BACKUP_DIR."
}

# Função de Restauração
restore() {
    echo "Iniciando restauração..."

    # Restauração de pacotes APT
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

    # Restauração dos dotfiles
    echo "Restaurando dotfiles..."
    cp -r "$BACKUP_DIR/.zshrc" "$HOME"
    cp -r "$BACKUP_DIR/.bashrc" "$HOME"
    cp -r "$BACKUP_DIR/.config" "$HOME/.config"
    cp -r "$BACKUP_DIR/share" "$HOME/.local"

    # Restauração do Powerlevel10k
    echo "Restaurando tema Powerlevel10k..."
    mkdir -p ~/.oh-my-zsh/custom/themes
    cp -r "$BACKUP_DIR/powerlevel10k" ~/.oh-my-zsh/custom/themes/powerlevel10k

    # Restauração de temas, fontes e extensões GNOME
    echo "Restaurando temas, fontes e extensões GNOME..."
    sudo cp -r "$BACKUP_DIR/themes" /usr/share/themes
    sudo cp -r "$BACKUP_DIR/icons" /usr/share/icons
    cp -r "$BACKUP_DIR/fonts" "$HOME/.local/share/fonts"
    cp -r "$BACKUP_DIR/gnome-extensions-user" ~/.local/share/gnome-shell/extensions
    sudo cp -r "$BACKUP_DIR/gnome-extensions-system" /usr/share/gnome-shell/extensions

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
