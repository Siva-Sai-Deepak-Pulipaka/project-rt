#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo bash get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Check if site name is provided as a command-line argument
if [ -z "$2" ]; then
    echo "Site name is missing. Please provide a site name as a command-line argument."
    exit 1
fi

site_name=$2

# Function to start the containers
start_site() {
    echo "Starting the WordPress site..."
    docker-compose up -d
    echo "WordPress site started."
}

# Function to stop the containers
stop_site() {
    echo "Stopping the WordPress site..."
    docker-compose down
    echo "WordPress site stopped."
}

# Function to delete the site
delete_site() {
    echo "Deleting the WordPress site..."
    stop_site
    cd ..
    rm -rf $site_name
    echo "WordPress site deleted."
}

# Function to display help
show_help() {
    echo "Usage: $0 [option] [site_name]"
    echo "Options:"
    echo "  create   - Create a new WordPress site"
    echo "  enable   - Start the WordPress site"
    echo "  disable  - Stop the WordPress site"
    echo "  delete   - Delete the WordPress site"
}

# Check if option is provided
if [ -z "$1" ]; then
    echo "Option is missing. Please provide an option."
    show_help
    exit 1
fi

option=$1

case $option in
    "create")
        # Create a directory for the WordPress site
        echo "Creating directory for the WordPress site..."
        mkdir -p $site_name
        cd $site_name