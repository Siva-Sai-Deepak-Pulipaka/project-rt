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
        cd $site_name || exit

        # Docker Compose file for the WordPress site
        cat <<EOF > docker-compose.yml
version: '3.9'
services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - db_data:/var/lib/mysql
  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    restart: always
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - ./wp-content:/var/www/html/wp-content
  nginx:
    image: nginx:latest
    restart: always
    ports:
      - 8080:80
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/wordpress:/var/www/html
volumes:
  db_data:
EOF

        # nginx configuration for handling php requests
        mkdir -p nginx/conf.d
        cat <<EOF > nginx/conf.d/default.conf
server {
    listen 80;
    server_name example.com;
    root /var/www/html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "upload_max_filesize = 64M \n post_max_size=64M";
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

        # Add /etc/hosts entry for example.com
        sudo sed -i "/example.com/d" /etc/hosts
        echo "127.0.0.1 example.com" | sudo tee -a /etc/hosts > /dev/null

        # Start the WordPress site
        start_site

        echo "WordPress site created successfully!"
        echo "Site URL: http://example.com:8080"
        echo "Site directory: $(pwd)"
        echo "Please wait for a moment and then try accessing the site."
        ;;
    "enable")
        start_site
        echo "WordPress site is now enabled."
        ;;
    "disable")
        stop_site
        echo "WordPress site is now disabled."
        ;;
    "delete")
        delete_site
        echo "WordPress site has been deleted."
        ;;
    *)
        echo "Invalid option. Please provide a valid option."
        show_help
        exit 1
        ;;
esac
