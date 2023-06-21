# project-rt

<p>The Project-RT script is a utility that simplifies the process of setting up and managing WordPress sites using Docker. It automates the creation, configuration, and deployment of a WordPress site along with its associated services such as Nginx, MySQL, and PHP-FPM precisely LEMP STACK.</p>

<h2> Run the script to create a new WordPress site </h2>

``` 
sudo bash proj-rt.sh create example.com
```
<p>This command will create a new directory for the WordPress site and start the necessary Docker containers.</p>

<h2>To Enable the WordPress site </h2>

```
sudo bash proj-rt.sh enable example.com
```

<p>This command will enable the WordPress site and make it accessible via the specified domain or IP address</p>

<h2>Customization</h2>
<p>The Project-RT script provides some options for customization. You can modify the following files to suit your specific requirements<p>

<ul><li>example.com/nginx/conf.d/default.conf: This file contains the Nginx configuration for the WordPress site. You can make changes to the server block, SSL settings, or any other Nginx directives.</ul>

<h2>Troubleshooting</h2>
If you encounter any issues or errors while using the script, you can refer to the following troubleshooting steps
<li>Check the script logs for any error messages

```
docker-compose logs
docker logs
```
<li>Verify that the necessary ports (e.g., 80, 443) are open in your security group settings.
<li>Make sure you have correctly configured the DNS or hosts file (in our case /etc/hosts) to point the domain or IP address to your server.
<h2>To Disable the WordPress site </h2>

```
sudo bash proj-rt.sh disable example.com
```

<h2>To Delete the WordPress site </h2>

```
sudo bash proj-rt.sh delete example.com
```
