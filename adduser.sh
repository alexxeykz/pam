#!/bin/bash
sudo useradd alex
sudo useradd wekx
sudo useradd days
echo "alex:252525" | sudo chpasswd
echo "wekx:252525" | sudo chpasswd
echo "days:252525" | sudo chpasswd
sudo groupadd admins
sudo groupadd weekends
sudo usermod -G admins alex
sudo usermod -G weekends wekx
sudo usermod -G admins vagrant
