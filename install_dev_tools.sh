#!/bin/bash

LOG_FILE="install.log"

# Функція для логування
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting environment setup..."

# Оновлення списку пакетів 
sudo apt-get update > /dev/null 2>&1

# 1. Перевірка та встановлення Docker
if ! command -v docker &> /dev/null; then
    log "Docker not found. Installing..."
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    log "Docker installed."
else
    log "Docker is already installed."
fi

# 2. Перевірка та встановлення Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log "Docker Compose not found. Installing..."
    sudo apt-get install -y docker-compose-plugin
    log "Docker Compose installed."
else
    log "Docker Compose is already installed."
fi

# 3. Перевірка Python 3.9+
if ! command -v python3 &> /dev/null; then
    log "Python3 not found. Installing..."
    sudo apt-get install -y python3 python3-pip
else
    PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if (( $(echo "$PY_VERSION < 3.9" | bc -l) )); then
        log "Python version $PY_VERSION is too old. Please upgrade manually or use pyenv."
    else
        log "Python $PY_VERSION found."
    fi
fi

# 4. Перевірка pip
if ! command -v pip3 &> /dev/null; then
    log "pip3 not found. Installing..."
    sudo apt-get install -y python3-pip
    log "pip3 installed."
else
    log "pip3 is already installed."
fi

# 5. Встановлення Python-бібліотек (Django, torch, torchvision, pillow)
LIBS=("django" "torch" "torchvision" "pillow")

for lib in "${LIBS[@]}"; do
    if python3 -c "import $lib" &> /dev/null; then
        log "Library '$lib' is already installed."
    else
        log "Installing '$lib'..."
        pip3 install "$lib" --break-system-packages 2>> "$LOG_FILE" || pip3 install "$lib" 2>> "$LOG_FILE"
        log "Library '$lib' installed."
    fi
done

log "Setup completed successfully."