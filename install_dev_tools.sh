#!/bin/bash

set -e

# Check docker
if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    echo "Installing Docker..."
    apt update
    apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Check docker compose
if command -v docker compose >/dev/null 2>&1; then
    echo "Docker Compose is already installed."
else
    echo "Installing Docker Compose..."
    sudo apt install -y docker-compose-plugin
fi

# Python
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python..."
    apt install -y python3
fi

echo "Installing Python tools (pip, venv)..."
apt install -y python3-pip python3-venv

# Django
DJANGO_VENV="/opt/django-venv"

if [ -d "$DJANGO_VENV" ]; then
    echo "Django virtualenv already exists at $DJANGO_VENV"
else
    echo "Creating Django virtualenv at $DJANGO_VENV"
    python3 -m venv "$DJANGO_VENV"
fi

"$DJANGO_VENV/bin/python" -m ensurepip --upgrade || true

echo "Installing pip in venv..." # weired error with pip not existing in the venv
"$DJANGO_VENV/bin/python" -m pip install --upgrade pip

echo "Installing Django into virtualenv..."
"$DJANGO_VENV/bin/pip" install --upgrade pip
"$DJANGO_VENV/bin/pip" install django

echo "Done."
