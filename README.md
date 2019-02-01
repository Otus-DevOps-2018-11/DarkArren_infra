# DarkArren_infra
DarkArren Infra repository

# HomeWork 05

## Connect to someinternalhost through bastion host
```
ssh -J Andrey.Abramov@35.233.76.110 Andrey.Abramov@10.132.0.3
```
## Connect to someinternal host using alias
Add to ~/.ssh/config
```
echo "Host bastion
    HostName 35.233.76.110
    User Andrey.Abramov

Host someinternalhost
    HostName 10.132.0.3
    User Andrey.Abramov
    ProxyJump bastion" >> ~/.ssh/config
```
Write in console
```
ssh someinternalhost
```

## Pritunl

### Users:
prinunl - prinunl
test - 6214157507237678334670591556762

### IPs:
bastion_IP = 35.233.76.110
someinternalhost_IP = 10.132.0.3

### Description:
На хосте 35.233.76.110 установлен prinunl-server по гайду, добавлен один пользователь и один сервер, подключение к серверу через OpenVPN Client, прежде чем подключаться в первый раз - не забывать запускать созданный VPN-сервер, он не стартует автоматически после создания.
После подключения к впн-серверу становится доступна внутрення инфраструктура.

# HomeWork 06
testapp_IP = 35.246.169.74
testapp_port = 9292

### Создать VM при помощи gcloud и настроить ее через startup-script
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=./startup_script.sh
```
### Создать VM при помощи gcloud и настроить ее через startup-script переданный по ссылке
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://storage.googleapis.com/darkarren_bucket/startup_script.sh
```
### Создать Firewall Rule для доступа на tcp порт 9292 при помощи gcloud
```
gcloud compute firewall-rules create default-puma-server\
    --network default \
    --priority 1000 \
    --direction ingress \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules TCP:9292
```
# HomeWork 07

### Провалидировать и создать образ reddit-base на основе packer-темплейта
```
cd ./packer && packer validate -var-file=variables.json ubuntu16.json && packer build -var-file=variables.json ubuntu16.json
```
### Провалидировать и создать immutable образ reddit-full на основе packer-темплейта
```
cd ./packer && packer validate -var-file=variables.json immutable.json && packer build -var-file=variables.json immutable.json
```
### Развернуть виртуальную машину на основе образа reddit-full
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --restart-on-failure \
  --tags puma-server
```
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

# HomeWork 09

## Задание со *

Настроено хранение terraform state в google cloud storage:

backend.tf:
```
terraform {
  backend "gcs" {
    bucket  = "storage-bucket-temp-prod"
    prefix  = "prod"
  }
}
```
main.tf
```
data "terraform_remote_state" "prod" {
  backend = "gcs"
  config {
    bucket  = "storage-bucket-temp-prod"
    prefix  = "prod"
  }
}
```
Проверена возможность запуска terraform apply из директории без terraform.tfstate

При запуске одновременно из двух разных директорий срабатывает блокировка исполнения:
```
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://storage-bucket-darkarren-prod/prod/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1548271474324722
  Path:      gs://storage-bucket-test-prod/prod/default.tflock
  Operation: OperationTypeApply
  Who:       user@machine.local
  Version:   0.11.9
  Created:   2019-01-23 19:24:34.23497 +0000 UTC
  Info:


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.

```

Задание с **

В модуль app добавлены provisioners:
```
  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }
  
  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'export DATABASE_URL=${var.db_internal_address}' >> ~/.profile",
      "export DATABASE_URL=${var.db_internal_address}",
      "sudo systemctl restart puma.service"
      ]
  }
```
Модуль app получает значение переменной db_internal_address из outputs модуля db, а затем, в процессе работы провижионера, добавляет это значение в переменные окружения, что позволяет приложениею reddit обратиться к базе данных MongoDB по правильному адресу

В модуль db добавлен provisioner:
```
  provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf",
    "sudo systemctl restart mongod.service",
    ]
  }
```
В результате работы провижионера изменяется конфигурационный файл mongod.config, что позволяет подключаться к базе отовсюду.

# HomeWork 10

## Базовое задание

Первый запуск ansible-playbook clone.yml
```
PLAY [Clone] **************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [appserver]

TASK [Clone repo] *********************************************************************************************************************
ok: [appserver]

PLAY RECAP ****************************************************************************************************************************
appserver                  : ok=2    changed=0    unreachable=0    failed=0
```
Второй запуск - после выполнения ansible app -m command -a 'rm -rf ~/reddit'

```
PLAY [Clone] **************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************
ok: [appserver]

TASK [Clone repo] *********************************************************************************************************************
changed: [appserver]

PLAY RECAP ****************************************************************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0
```

После удаления директории reddit и повторного запуска плейбка clone.yml изменился статус после сообщения.
В первом случае папка уже была, поэтому выполнение плейбука, по сути, не вносило никаких изменений.
Во втором случае - репозиторий был загружен, соответственно второй таск внес изменения, что и отобразилось в логе.

## Задание со *

Подготовлен скрипт на python - ./py_inv/dynamic_inventory.py:

```
#!/usr/local/bin/python3

import googleapiclient.discovery
from optparse import OptionParser
import os

gce_project = os.environ.get("GOOGLE_COMPUTE_PROJECT")
gce_zone = os.environ.get("GOOGLE_COMPUTE_ZONE")

parser = OptionParser()
parser.add_option('--list', action="store_true", dest='return_list')

(options, arguments) = parser.parse_args()

inventory_template = {}

compute = googleapiclient.discovery.build('compute', 'v1')

result = compute.instances().list(project=gce_project, zone=gce_zone).execute()

if options.return_list:
    for i in result.get("items"):
        gcloud_instance_name = i.get("name")
        gcloud_instance_nat_ip = i.get("networkInterfaces")[0].get("accessConfigs")[0].get('natIP')
        inventory_template[gcloud_instance_name] = {"hosts": [gcloud_instance_nat_ip]}

inventory_template["_meta"] = {"hostvars": {}}
print(inventory_template)

```

перед использованием скрипта для динамического инвентори необходимо выполнить:
```
pip3 install google-api-python-client
export GOOGLE_APPLICATION_CREDENTIALS=/Users/appuser/Infra-123.json
export GOOGLE_COMPUTE_PROJECT=infra-234156
export GOOGLE_COMPUTE_ZONE=europe-west1-b
```
GOOGLE_APPLICATION_CREDENTIALS - путь до json-файла сервисного аккаунта
GOOGLE_COMPUTE_PROJECT - имя проекта в котором находятся инстансы
GOOGLE_COMPUTE_ZONE - имя зоны где находятся инстансы

Результат запуска:
```
ansible all -m ping -i dynamic_invetory.py

34.76.196.130 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
34.76.126.255 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

В ansible.cfg добавлено:
```
inventory = ./
inventory_ignore_extensions = ~, inventory, .cfg, .yml, .json, .txt, .ini
[inventory]
enable_plugins = script
```

В inventory_ignore_extensions добавлено "inventory", так как иным образом ансибл не хотел игнорировать инвентори без расширения, судя по всему используется .endswith(), поэтому в таком виде удается игнорировать все, кромен нужного .py-скрипта. 
