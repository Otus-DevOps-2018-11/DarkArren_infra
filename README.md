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


# HomeWork 06
testapp_IP = 35.246.169.74
testapp_port = 9292

# Создать VM при помощи gcloud и настроить ее через startup-script
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup_script.sh

# Создать VM при помощи gcloud и настроить ее через startup-script переданный по ссылке
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://storage.googleapis.com/darkarren_bucket/startup_script.sh

# Создать Firewall Rule для доступа на tcp порт 9292 при помощи gcloud
gcloud compute firewall-rules create default-puma-server\
    --network default \
    --priority 1000 \
    --direction ingress \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules TCP:9292
