!/bin/bash
# This script is intended to setup the environment for a NGINX Web Server with SSL certificate using Let's Encrypt.

# Get latest updates
echo ""
echo "UPDATING SYSTEM..."
echo ""
sudo apt update
clear

# Get install nginx
sudo apt-get -y install nginx
clear

# install certbot
sudo snap install core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
clear


# setup reverse proxy & ssl
PROJECT_DIR_NGINX_AVAILABLE="/etc/nginx/sites-available"
PROJECT_DIR_NGINX_ENABLED="/etc/nginx/sites-enabled"
CURRENT_DIR=$(pwd)

cd ${PROJECT_DIR_NGINX_AVAILABLE}
pwd

# frontend
sudo rm -rf ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com
sudo rm -rf ${PROJECT_DIR_NGINX_ENABLED}/stag.domain.com

sudo touch ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com

echo 'server {
            server_name stag.domain.com;
            
            access_log /var/log/nginx/stag.domain.com-access.log;
            error_log /var/log/nginx/stag.domain.com-error.log;

            location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://IP:8081;
            }
        }' | sudo tee ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com

# copy with symlink
sudo ln -s ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com ${PROJECT_DIR_NGINX_ENABLED}/

# setup certbot
sudo certbot --nginx certonly -n -d stag.domain.com


# backend
sudo rm -rf ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com
sudo rm -rf ${PROJECT_DIR_NGINX_ENABLED}/api.domain.com

sudo touch ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com

echo 'server {
            server_name api.domain.com;
            
            access_log /var/log/nginx/api.domain.com-access.log;
            error_log /var/log/nginx/api.domain.com-error.log;

            location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://IP:8080;
            }
        }' | sudo tee ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com

# copy with symlink
sudo ln -s ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com ${PROJECT_DIR_NGINX_ENABLED}/

# check status nginx config
sudo nginx -t

# setup certbot
sudo certbot --nginx -n -d api.domain.com
sudo certbot --nginx -n -d stag.domain.com

# restart nginx 
sudo systemctl restart nginx
clear

echo ""
echo "INSTALLING NGINX && SSL DONE"
echo ""
