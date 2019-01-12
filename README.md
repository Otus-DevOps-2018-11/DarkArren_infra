# DarkArren_infra
DarkArren Infra repository

# HomeWork 05

# Connect to someinternalhost through bastion host
ssh -J Andrey.Abramov@35.233.76.110 Andrey.Abramov@10.132.0.3

# Connect to someinternal host using alias
# Add to ~/.ssh/config
echo "Host bastion
    HostName 35.233.76.110
    User Andrey.Abramov

Host someinternalhost
    HostName 10.132.0.3
    User Andrey.Abramov
    ProxyJump bastion" >> ~/.ssh/config

# Write in console
ssh someinternalhost

# Pritunl
# Users:
prinunl - prinunl
test - 6214157507237678334670591556762
# IPs:
bastion_IP = 35.233.76.110
someinternalhost_IP = 10.132.0.3
# Description:
На хосте 35.233.76.110 установлен prinunl-server по гайду, добавлен один пользователь и один сервер, подключение к серверу через OpenVPN Client, прежде чем подключаться в первый раз - не забывать запускать созданный VPN-сервер, он не стартует автоматически после создания.
После подключения к впн-серверу становится доступна внутрення инфраструктура.



