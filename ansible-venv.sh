#!/bin/bash

# Function to check if a command exists
command_exists () {
    command -v "$1" >/dev/null 2>&1
}

# Detect the operating system
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command_exists apt; then
        OS="debian"
    elif command_exists dnf; then
        OS="redhat"
    elif command_exists yum; then
        OS="redhat"
    elif command_exists pacman; then
        OS="arch"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

# Step 1: Ensure Python 3 is installed based on OS
install_python () {
    case "$OS" in
        debian)
            echo "Detected Debian-based system. Installing Python 3..."
            sudo apt update
            sudo apt install -y python3 python3-venv python3-pip
            ;;
        redhat)
            echo "Detected Red Hat-based system. Installing Python 3..."
            sudo dnf install -y python3 python3-virtualenv python3-pip || sudo yum install -y python3 python3-virtualenv python3-pip
            ;;
        arch)
            echo "Detected Arch-based system. Installing Python 3..."
            sudo pacman -Syu --noconfirm python python-pip
            ;;
        macos)
            echo "Detected macOS. Installing Python 3 with Homebrew..."
            if ! command_exists brew; then
                echo "Homebrew is not installed. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install python
            ;;
        *)
            echo "Unsupported OS. Exiting..."
            exit 1
            ;;
    esac
}

# Check if Python 3 is installed, if not install it
if ! command_exists python3; then
    install_python
else
    echo "Python 3 is already installed."
fi

# Step 2: Create a virtual environment
VENV_DIR=".venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating a Python virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists in $VENV_DIR."
fi

# Step 3: Activate the virtual environment
echo "Activating the virtual environment..."
source "$VENV_DIR/bin/activate"

# Step 4: Install Ansible and dependencies from requirements.txt
if [ -f "requirements.txt" ]; then
    echo "Installing Ansible and other dependencies from requirements.txt..."
    pip install -r requirements.txt
else
    echo "requirements.txt file not found. Skipping Python dependencies installation."
fi

# Step 5: Install Ansible Galaxy roles from requirements.yml
if [ -f "requirements.yml" ]; then
    echo "Installing Ansible Galaxy roles from requirements.yml..."
    ansible-galaxy install -r requirements.yml
else
    echo "requirements.yml file not found. Skipping Ansible Galaxy roles installation."
fi

# Step 6: Print message
echo "Ansible environment setup complete. You are now inside the virtual environment."

# No need to exec, as the user will be sourced into the environment naturally

