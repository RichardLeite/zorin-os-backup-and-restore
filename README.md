# Zorin OS - Backup and Restore

Script para backup e restauração de configurações do Zorin OS, incluindo temas, extensões GNOME, fontes e dotfiles.

## Instalação

Clone o repositório:

```bash
git clone https://github.com/RichardLeite/zorin-os-backup-and-restore.git
cd zorin-os-backup-and-restore
```

## Permissões de execução

```bash
chmod +x backup_restore.sh
```

## Utilização

Para executar o script, basta executar o comando:

```bash
sudo ./backup_restore.sh
```

## Opções Disponíveis

### 1. Configuração

- Define diretórios para backup e restauração
  - [x] Opção padrão: Diretório atual
  - [x] Opção personalizada: Diretório personalizado

### 2. Backup

- Dotfiles
  - [x] .zshrc
  - [x] .bashrc

- Configurações
  - [x] .config
  - [x] dconf

- Temas e Personalização
  - [x] Powerlevel10k
  - [x] Temas GNOME
  - [x] Ícones
  - [x] Fontes
  - [x] Extensões GNOME

- Pacotes Instalados
  - [x] APT
  - [x] Snap
  - [x] Flatpak

### 3. Restore:

- Restauração completa das configurações
  - [x] Requer arquivo backup.tar.xz no diretório configurado
  - [x] Restaura todas as configurações salvas no backup

### 4. Sair

- Finaliza a execução do programa

## Arquivos Gerados

- configuration.conf: Arquivo de configuração
- backup.tar.xz: Arquivo compactado com backup completo

## Requisitos

- Zorin OS (Ou qualquer distro baseado em Ubuntu)
- Terminal com acesso root para algumas operações
- Git para clonar o repositório