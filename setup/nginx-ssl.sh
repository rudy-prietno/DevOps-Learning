# install nginx
sudo apt-get update
sudo apt-get install nginx

# setup nginx
cd /etc/nginx/sites-available

# define new file & rename like your domain
- touch stag.aktifitasacak.com

# sudo nano stag.aktifitasacak.com
# insert this command 
sudo 'echo "server {
                     listen 80;
                     listen [::]:80;

                     server_name stag.aktifitasacak.com;
                     access_log /var/log/nginx/stag.aktifitasacak.com-access.log;
                     error_log /var/log/nginx/stag.aktifitasacak.com-error.log;

                     location / {
                          proxy_set_header Host $host;
                          proxy_set_header X-Real-IP $remote_addr;
                          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                          proxy_pass http://{replace with IP instance}:8080;
                     }
              }" >> stag.aktifitasacak.com'

sudo nginx -t

# copy with symlink
sudo ln -s /etc/nginx/sites-available/stag.aktifitasacak.com /etc/nginx/sites-enabled/

cd /etc/nginx/sites-enabled

sudo systemctl restart nginx
tail -f /var/log/nginx/stag.aktifitasacak.com-error.log


# https://certbot.eff.org/ setup ssl using certbot
sudo snap install core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
sudo systemctl restart nginx
