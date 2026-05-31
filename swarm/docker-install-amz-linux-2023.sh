#!/bin/bash
#exit the script immediately if any command fails
set -e

# Trace execution (echo each line before it runs)
set -x

# Determine the target user. 
# If $USER is empty or root, we default to 'ec2-user'.
TARGET_USER="$USER"

if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    echo "Current user is empty or root. Defaulting to ec2-user since script is for Amazon Linux 2023."
    TARGET_USER="ec2-user"
fi

echo "Updating packages..."
sudo dnf update -y

echo "Installing required packages..."
sudo dnf install -y \
    docker \
    git \
    bash-completion

echo "Starting and enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding your user ($TARGET_USER) to the docker group..."
sudo usermod -aG docker "$TARGET_USER"

echo "Setting up Docker CLI auto-completion..."
# This enables docker auto-complete in your shell
DOCKER_COMPLETION_FILE="/etc/bash_completion.d/docker"
if [ ! -f "$DOCKER_COMPLETION_FILE" ]; then
    echo "Downloading Docker bash completion script..."
    sudo curl -L https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker -o "$DOCKER_COMPLETION_FILE"
fi

echo "Reloading bash completion..."
source /etc/profile.d/bash_completion.sh || true
source "$DOCKER_COMPLETION_FILE" || true

echo "All done! You may need to log out and log back in for group changes to take effect."
echo "Test docker is installed with: docker version"
echo "!!! Ensure you are the $TARGET_USER when executing docker commands (i.e: sudo su ec2-user) !!!"
