#!/bin/bash
BRed='\033[1;31m'
BGreen='\033[1;32m'
NC='\033[0m' # No Color

echo -e "${BGreen}Please enter the subdomain for your relay${NC}"
read domain_name
# Update deps
sudo apt update

# Install nodejs, npm, nginx, certbot
sudo apt install nodejs npm nginx certbot python3-certbot-nginx -y

# Setup Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Setup `apt` Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y

# Check installation is successful by checking verions
docker --version
npm --version
node --version

# Clone `nostream` repo
git clone https://github.com/Cameri/nostream.git

cd nostream

# Delete the default nginx settings file
rm -rf /etc/nginx/sites-available/default

# Paste in new settings file contents (see heading NGINX SETTINGS below)
#sudo nano /etc/nginx/sites-available/default
sudo tee /etc/nginx/sites-available/default <<EOF
server{
    server_name ${domain_name};
    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8008;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
# Restart nginx
sudo service nginx restart

# Map DNS A record to IP of VM machine (see DNS SETTINGS below)

# Request SSL cert from letsencrypt/certbot
sudo certbot --nginx -d subdomain.mydomain.com