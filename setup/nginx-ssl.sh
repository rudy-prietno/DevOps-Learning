#! /bin/bash
# This script is intended to setup the environment for a NGINX Web Server with SSL certificate using Let's Encrypt.


# install nginx
install_nginx(){
    sudo apt-get update && \
    sudo apt-get install nginx snapd -y
    # Get latest updates
    echo ""
    echo "UPDATING SYSTEM & SETUP NGINX..."
    echo ""
}


# install certbot
install_certbot(){
    sudo apt-get update && \
    sudo snap install core; sudo snap refresh core && \
    sudo snap install --classic certbot && \
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    echo ""
    echo "UPDATING SYSTEM & SETUP CERTBOT..."
    echo ""
}



# setup reverse proxy & ssl
# variable
DOMAINFE="stag.domain.com"
DOMAINBE="api.domain.com"
NGINX=$(sudo nginx -v)
CERTBOT=$(sudo certbot --version)
CERTIFICATEFE=$(sudo certbot certificates | grep $DOMAINFE)
CERTIFICATEBE=$(sudo certbot certificates | grep $DOMAINBE)
PROJECT_DIR_NGINX_AVAILABLE="/etc/nginx/sites-available"
PROJECT_DIR_NGINX_ENABLED="/etc/nginx/sites-enabled"


# frontend
frontend_ssl() {
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
                    proxy_pass http://localhost:8081;
                }
            }' | sudo tee ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com

    # copy with symlink
    sudo ln -s ${PROJECT_DIR_NGINX_AVAILABLE}/stag.domain.com ${PROJECT_DIR_NGINX_ENABLED}/

    # setup certbot
    sudo certbot --nginx -n -d stag.domain.com

    # restart nginx 
    sudo systemctl restart nginx
}


# backend
backend_ssl() {
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
                    proxy_pass http://localhost:8080;
                }
            }' | sudo tee ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com

    # copy with symlink
    sudo ln -s ${PROJECT_DIR_NGINX_AVAILABLE}/api.domain.com ${PROJECT_DIR_NGINX_ENABLED}/

    # check status nginx config
    sudo nginx -t

    # setup certbot
    sudo certbot --nginx -n -d api.domain.com

    # restart nginx 
    sudo systemctl restart nginx
}


# run function
if [[ $NGINX == *"nginx version: nginx/1.18.0 (Ubuntu)"* ]]; then
    install_nginx
fi

if [[ $CERTBOT == *"certbot 1.32.0"* ]]; then
    install_certbot
fi

if [[ $CERTIFICATEBE == *"Domains: $DOMAINBE"* ]]; then
    backend_ssl
fi

if [[ $CERTIFICATEFE == *"Domains: $DOMAINFE"* ]]; then
    frontend_ssl
fi


echo ""
echo "INSTALLING NGINX && SSL DONE"
echo ""
