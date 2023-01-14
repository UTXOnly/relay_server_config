#!/bin/bash
BGreen='\u001b[32;1m'
NC='\033[0m'
echo -e "${BGreen}Please enter the username you could like to create and press ENTER:${NC} "
read USERNAME

sudo useradd -m $USERNAME -s /bin/bash #$USERNAME 
sudo passwd $USERNAME 
sudo usermod -aG sudo $USERNAME

sudo sed '/force_color_prompt=yes/s/^#//' -i ~/.bashrc

echo -e "${BGreen}\nUser $USERNAME created! moving on.....${NC}"