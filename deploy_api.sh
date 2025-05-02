#!/bin/bash

set -e

REPO_URL="https://github.com/sin4ch/number_classification_api.git"
PROJECT_DIR="number_classification_api"
IMAGE_NAME="armstrong-api"
CONTAINER_NAME="armstrong-container"
NGINX_CONF_FILE="armstrong-api"

if [ -z "$1" ]; then
  echo "Usage: $0 <your_domain_or_public_ip>"
  exit 1
fi
SERVER_NAME=$1

echo "--- Starting Deployment for $SERVER_NAME ---"

echo "Updating system packages..."
sudo apt update -y

echo "Installing Git and Docker..."
sudo apt install git docker.io -y

echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding current user ($USER) to the docker group..."
sudo usermod -aG docker $USER
echo "!!! IMPORTANT: You may need to log out and log back in for Docker group changes to take effect fully !!!"
# newgrp docker || true # Keep this commented or remove if not needed

echo "Cloning repository from $REPO_URL..."
if [ -d "$PROJECT_DIR" ]; then
  echo "Removing existing project directory $PROJECT_DIR..."
  rm -rf "$PROJECT_DIR"
fi
git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"
echo "Successfully cloned and entered $PROJECT_DIR"

echo "Building Docker image $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" .

echo "Checking for existing container $CONTAINER_NAME..."
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping existing container $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME"
fi
if [ "$(docker ps -aq -f status=exited -f name=$CONTAINER_NAME)" ]; then
    echo "Removing existing container $CONTAINER_NAME..."
    docker rm "$CONTAINER_NAME"
fi

echo "Running Docker container $CONTAINER_NAME..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 127.0.0.1:8000:8000 \
  --restart always \
  "$IMAGE_NAME"

echo "Container $CONTAINER_NAME started."

echo "Installing Nginx..."
sudo apt install nginx -y

echo "Configuring Nginx for $SERVER_NAME..."
NGINX_CONFIG_PATH="/etc/nginx/sites-available/$NGINX_CONF_FILE"

sudo bash -c "cat > $NGINX_CONFIG_PATH" <<EOF
server {
    listen 80;
    server_name $SERVER_NAME;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "Nginx config created at $NGINX_CONFIG_PATH"

echo "Enabling Nginx site..."
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "Removing default Nginx site link..."
    sudo rm /etc/nginx/sites-enabled/default
fi
if [ ! -L "/etc/nginx/sites-enabled/$NGINX_CONF_FILE" ]; then
    echo "Creating Nginx site link..."
    sudo ln -s "$NGINX_CONFIG_PATH" "/etc/nginx/sites-enabled/"
else
    echo "Nginx site link already exists."
fi

echo "Testing Nginx configuration..."
sudo nginx -t
echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "--- Deployment Complete ---"
echo "Your API should be accessible at http://$SERVER_NAME"
echo "Consider setting up HTTPS using Certbot for security."
echo "Remember to log out and back in if you encounter Docker permission issues."
