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

# HomeWork 07

# Провалидировать и создать образ reddit-base на основе packer-темплейта
 cd ./packer && packer validate -var-file=variables.json ubuntu16.json && packer build -var-file=variables.json ubuntu16.json

# Провалидировать и создать immutable образ reddit-full на основе packer-темплейта
cd ./packer && packer validate -var-file=variables.json immutable.json && packer build -var-file=variables.json immutable.json

# Развернуть виртуальную машину на основе образа reddit-full
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --restart-on-failure \
  --tags puma-server

# HomeWork 08

## Задание со *
  
### Добавление ssh-ключа пользователя в метаданные проекта
```
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "abramov1:${file(var.public_key_path)}"
  }
}
``` 
### Добавление нескольких ssh-ключей в метаданные проекта
```
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "abramov1:${file(var.public_key_path)} abramov2:${file(var.public_key_path)} abramov3:${file(var.public_key_path)} abramov4:${file(var.public_key_path)} abramov5:${file(var.public_key_path)}"
  }
}
```
### Возникающая проблема
Если в метаданные проекта добавить ssh-ключ через web-интерфейс Google Cloud, а затем запустить terraform apply,
то в результате в метаданных проектах останутся только те ключи, которые описаны в проекте terraform, добавленный вручную ключ исчезнет.

## Задание с **

### Возникающие проблемы
1. Необходимо все так же открывать приложение с использованием порта 9292, хоть и указывая адрес балансировщика, а не самой машины с приложением.
2. Для каждого инстанса приложения необходимо заново прописывать ресурс google_compute_instance, что ведет к разрастанию проекта и возможностям ошибки (инстансы в итоге могут получиться неодинаковыми)
3. В ресурс google_compute_target_pool необходимо вручную добавлять инстансы по именам, что, опять-таки, неудобно и ведет к ошибкам.

При добавлении параметра count необходимо кастомизировать имя создаваемого инстнса, например добавляя индекс count к имени машины.
