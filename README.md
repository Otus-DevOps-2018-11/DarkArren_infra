# DarkArren_infra
DarkArren Infra repository

[![Build Status](https://travis-ci.com/Otus-DevOps-2018-11/DarkArren_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2018-11/DarkArren_infra)

<details>
  <summary>HomeWork 05</summary>

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
</details>


<details>
  <summary>HomeWork 06</summary>

  # HomeWork 06
  testapp_IP = 35.246.169.74
  testapp_port = 9292

  ### Создать VM при помощи gcloud и настроить ее через startup-script
  ```
  gcloud compute instances create app\
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
  gcloud compute instances create app\
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
</details>


<details>
  <summary>HomeWork 07</summary>

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
  gcloud compute instances create app\
    --boot-disk-size=10GB \
    --image-family reddit-full \
    --machine-type=g1-small \
    --zone=europe-west3-c \
    --restart-on-failure \
    --tags puma-server
  ```
</details>


<details>
  <summary>HomeWork 08</summary>

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
</details>

<details>
  <summary>HomeWork 09</summary>

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
</details>

<details>
  <summary>HomeWork 10</summary>
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

  ### Решение 1 (для прохождения автотестов)

  Подготовлен скрипт на bash - ./dynamic_invetory.sh

  ```
  #!/bin/bash
  cat ./inventory.json
  ```

  В ansible.cfg добавлено:
  ```
  inventory = ./
  inventory_ignore_extensions = ~, inventory, .cfg, .yml, .json, .txt, .ini, .py
  [inventory]
  enable_plugins = script
  ```

  В inventory_ignore_extensions добавлено "inventory", так как иным образом ансибл не хотел игнорировать инвентори без расширения, судя по всему используется .endswith(), поэтому в таком виде удается игнорировать все, кромен нужного .sh-скрипта. 

  ### Решение 2 (для души и практики работы с api)
  Подготовлен скрипт на python - ./dynamic_inventory.py:

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
</details>

<details>
  <summary>HomeWork 11</summary>

  # HomeWork 11

  - Закомментированы провижионеры в модулях app и db в ./terraform/module

  ## Один playbook один сценарий

  - В .gitignore добавлен *.retry
  - Создан reddit_app.yml, значение hosts задано all
  - Добавлен сценарий для конфигурирования MongoDB с использованием шаблона конфигурационного файла и отдельного тега db-tag
  - Задана переменная (bindIP), произведена проверка playbook
  - Добавлен handler, перезапускающий сервис mongod в слуае изменения конфигурационного файла
  - Применены изменения описанные в сценарии
  - Подготовлен новый unit-файл для puma (адрес DB-сервера будет браться из файла, а не из env)
  - Добавлены таски для копирования на целевую машину unit-файла и enable puma.service, таски помечпны тегом app-tag
  - Добавлен handler для перезапуска puma.service
  - Добавлен шаблон для конфигурационного файла puma.service (в который будет передан адрес DB-сервера)
  - Добавлен таск для копирования шаблона на целевую машину, задано значение переменной (тег app-tag)
  - Playbook запущен с тегом  app-tag
  - Добавлены таски на клонированиея репозитория с приложеним и установке зависимостей (тег deploy-tag)
  - Playbook запущен с тегом deploy-tag, проверена работоспособность приложения

  ## Один playbook несколько сценариев

  - Создан playbook reddit-app2.yml
  - На основе тасков из предыдущего playbook добавлен сценарий для конфигурирования MongoDB, параметр hosts: db (сценарий будет выполняться только для db-серверов)
  - На основе тасков из предыдущего playbook добавлен сценарий для конфигурирования app-сервера - hosts: app
  - Добавлен сценарий для деплоя приложения (hosts: app)
  - Проверена рабоспособность такого сценария

  ## Несколько playbooks

  - Созданы playbooks app.yml, db.yml, deploy.yml
  - В плейбуки перенесены соответствующий сценарии (конфигурирование MongoDB, конфигурирование app-сервера, deploy приложения)
  - Создан site.yml, в который импортированы app.yml, db.yml, deploy.yml
  - Проверена работоспособность поулчившихся playbooks 

  ## Задание со *

  После некоторого раздумья все-таки остановился на gce.py, т.к. оказалось, что в предыдущей домашней работе я придумал велосипед написав собственный вариант скрипта для генерации dynamic inventory на том же питоне, соответственно уже успел ознакомиться с созданием service account и авторизацией через service account. Учитывая что это python, то я, при необходимости, могу исправить gce.py под мои нужды (что и пришлось сделать чтоыб убрать Deprecated Warning).

  Не стал останавливаться на самописном скрипте dynamic_inventory.py, так как не уверен, насколько плотно придется использовать его в будущих домашних заданиях и хватит ли мне питоньих скиллов чтобы все что нужно реализовать и поддерживать, в любом случае, оставлю себе и этот вариант для дальнейшего развития.

  Из минусов gce.py, пришлось изменить имена машин в сценария терраформа, так как я использовал везде reddit-app и reddit-db, вместо app и db соответственно, и если в своем скрипте я это просто обошел через endwith и хардкод, то здесь лишние правки в gce.py вносить не стал и просто исправил сценарии (в связи с этим в MR будет значительное количество измененных файлов).

  Положил gce.py и gce.ini в отдельную директорию, настроил, внес изменения в ansible.cfg, проверил работу.

  ## Провижининг в Packer 

  - Создал плейбуки packer_app.yml и packer_db.yml
  - Перенес в плейбуки те действия, что раньше выполнялись шелл-скриптами
  - Перебилдил образы с использованием provisioners: ansible
  - Пересоздал окружение stage с использованием новых образов
  - Проверил работу site.yml и работоспособность приложения
</details>

# HomeWork 12

## Перенос плейбуков в роли

- Посредством ansible-galaxy init созданы заготовки ролей для app и db
- В ansible/roles/db/tasks/main.yml перенесены таски из плейбука ansible/db.yml
- В ansible/roles/db/hadnlers/main.yml перенесены используемые хэндлеры из ansible/db.yml
- В ansible/roles/db/templates скопирован шаблон конфига MongoDB
- В ansible/roles/db/defaults/main.yml определеные переменные, которые используются в конфиге
- Аналогично db в роль app перенесены таски, хэндлеры, темплеты и определены переменные
- Плейбуки ansible/app.yml и ansible/db.yml переделаны на использование ролей, вместо тасков
- Переразвернул инфраструктуру в terraform
- Выполнил ansible-playbook site.yml
```
ansible-playbook site.yml

PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [db]

TASK [db : Change mongo config file] ***********************************************************************************************************************************************************************
changed: [db]

RUNNING HANDLER [db : restart mongod] **********************************************************************************************************************************************************************
changed: [db]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [app]

TASK [app : Add unit file for Puma] ************************************************************************************************************************************************************************
changed: [app]

TASK [app : Add config for DB connection] ******************************************************************************************************************************************************************
changed: [app]

TASK [app : enable puma] ***********************************************************************************************************************************************************************************
changed: [app]

RUNNING HANDLER [app : reload puma] ************************************************************************************************************************************************************************
changed: [app]

PLAY [Intall reddit] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [app]

TASK [Fetch the latest version of application code] ********************************************************************************************************************************************************
changed: [app]

TASK [Bundle install] **************************************************************************************************************************************************************************************
changed: [app]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [app]

PLAY RECAP *************************************************************************************************************************************************************************************************
app                        : ok=9    changed=7    unreachable=0    failed=0
db                         : ok=3    changed=2    unreachable=0    failed=0

```
 - Проверил работоспособность приложения

## Окружения

 - Создал директории для окружений - ansible/environments/stage и ansible/environments/prod
 - Перенес inventory из ansible в директории окружений
 - Создана директория group_vars и файлы app и db в ней, в которых определены переменные для соответствующих групп
 - Добавлен файл all с определением окружений
 - Аналогичным образом созданы group_vars для окружения prod
 - В ролях app и db определены переменные для окружения
 - Добавлен таск, выводящий информацию об окружении, в котором запущена роль
 - Организованы плейбуки и прочие файлы директории ansible
 - Исправлен путь к плейбукам в провижионерах packer
 - Внесены улучшения в ansible.cfg
 - Пересоздана инфраструктура для окружения stage при помощи terraform
 - Проверена работа ansible через ansible-playbook playbooks/site.yml
  
```
ansible-playbook playbooks/site.yml

PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [dbserver]

TASK [db : Show info about the env this host belongs to] ***************************************************************************************************************************************************
ok: [dbserver] => {
    "msg": "This host is in stage environment!!!"
}

TASK [db : Change mongo config file] ***********************************************************************************************************************************************************************
--- before: /etc/mongod.conf
+++ after: /Users/4rren/.ansible/tmp/ansible-local-38187k47ksj9l/tmpclnzu9jg/mongod.conf.j2
@@ -1,41 +1,16 @@
-# mongod.conf
-
-# for documentation of all options, see:
-#   http://docs.mongodb.org/manual/reference/configuration-options/
-
 # Where and how to store data.
 storage:
   dbPath: /var/lib/mongodb
   journal:
     enabled: true
-#  engine:
-#  mmapv1:
-#  wiredTiger:

 # where to write logging data.
 systemLog:
   destination: file
   logAppend: true
   path: /var/log/mongodb/mongod.log

 # network interfaces
 net:
   port: 27017
-  bindIp: 127.0.0.1
-
-
-#processManagement:
-
-#security:
-
-#operationProfiling:
-
-#replication:
-
-#sharding:
-
-## Enterprise-Only Options:
-
-#auditLog:
-
-#snmp:
+  bindIp: 0.0.0.0

changed: [dbserver]

RUNNING HANDLER [db : restart mongod] **********************************************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [app : Show info about the env this host belongs to] **************************************************************************************************************************************************
ok: [appserver] => {
    "msg": "This host is in stage environment!!!"
}

TASK [app : Add unit file for Puma] ************************************************************************************************************************************************************************
--- before
+++ after: /Users/4rren/git/otus/DarkArren_infra/ansible/roles/app/files/puma.service
@@ -0,0 +1,14 @@
+[Unit]
+Description=Puma HTTP Server
+After=network.target
+
+[Service]
+Type=simple
+EnvironmentFile=/home/abramov/db_config
+User=abramov
+WorkingDirectory=/home/abramov/reddit
+ExecStart=/bin/bash -lc 'puma'
+Restart=always
+
+[Install]
+WantedBy=multi-user.target

changed: [appserver]

TASK [app : Add config for DB connection] ******************************************************************************************************************************************************************
--- before
+++ after: /Users/4rren/.ansible/tmp/ansible-local-38187k47ksj9l/tmpm5p7kufs/db_config.j2
@@ -0,0 +1 @@
+DATABASE_URL=10.132.15.221

changed: [appserver]

TASK [app : enable puma] ***********************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [app : reload puma] ************************************************************************************************************************************************************************
changed: [appserver]

PLAY [Intall reddit] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ********************************************************************************************************************************************************
>> Newly checked out 5c217c565c1122c5343dc0514c116ae816c17ca2
changed: [appserver]

TASK [Bundle install] **************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=10   changed=7    unreachable=0    failed=0
dbserver                   : ok=4    changed=2    unreachable=0    failed=0
```
 - Пересоздана инфраструктура для окружения Prod при помощи terraform
 - Внесены новые значния IP в environments/prod/inventory и в envrinoments/prod/group_vars/app
 - Проверена работа плейбука site.yml
```
ansible-playbook -i environments/prod/inventory playbooks/site.yml

PLAY [Configure MongoDB] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [dbserver]

TASK [db : Show info about the env this host belongs to] ***************************************************************************************************************************************************
ok: [dbserver] => {
    "msg": "This host is in prod environment!!!"
}

TASK [db : Change mongo config file] ***********************************************************************************************************************************************************************
--- before: /etc/mongod.conf
+++ after: /Users/4rren/.ansible/tmp/ansible-local-39554hyh1j9os/tmp9c3aveul/mongod.conf.j2
@@ -1,41 +1,16 @@
-# mongod.conf
-
-# for documentation of all options, see:
-#   http://docs.mongodb.org/manual/reference/configuration-options/
-
 # Where and how to store data.
 storage:
   dbPath: /var/lib/mongodb
   journal:
     enabled: true
-#  engine:
-#  mmapv1:
-#  wiredTiger:

 # where to write logging data.
 systemLog:
   destination: file
   logAppend: true
   path: /var/log/mongodb/mongod.log

 # network interfaces
 net:
   port: 27017
-  bindIp: 127.0.0.1
-
-
-#processManagement:
-
-#security:
-
-#operationProfiling:
-
-#replication:
-
-#sharding:
-
-## Enterprise-Only Options:
-
-#auditLog:
-
-#snmp:
+  bindIp: 0.0.0.0

changed: [dbserver]

RUNNING HANDLER [db : restart mongod] **********************************************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [app : Show info about the env this host belongs to] **************************************************************************************************************************************************
ok: [appserver] => {
    "msg": "This host is in prod environment!!!"
}

TASK [app : Add unit file for Puma] ************************************************************************************************************************************************************************
--- before
+++ after: /Users/4rren/git/otus/DarkArren_infra/ansible/roles/app/files/puma.service
@@ -0,0 +1,14 @@
+[Unit]
+Description=Puma HTTP Server
+After=network.target
+
+[Service]
+Type=simple
+EnvironmentFile=/home/abramov/db_config
+User=abramov
+WorkingDirectory=/home/abramov/reddit
+ExecStart=/bin/bash -lc 'puma'
+Restart=always
+
+[Install]
+WantedBy=multi-user.target

changed: [appserver]

TASK [app : Add config for DB connection] ******************************************************************************************************************************************************************
--- before
+++ after: /Users/4rren/.ansible/tmp/ansible-local-39554hyh1j9os/tmplznn3c2r/db_config.j2
@@ -0,0 +1 @@
+DATABASE_URL=10.132.15.225

changed: [appserver]

TASK [app : enable puma] ***********************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [app : reload puma] ************************************************************************************************************************************************************************
changed: [appserver]

PLAY [Intall reddit] ***************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ********************************************************************************************************************************************************
>> Newly checked out 5c217c565c1122c5343dc0514c116ae816c17ca2
changed: [appserver]

TASK [Bundle install] **************************************************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] ******************************************************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *************************************************************************************************************************************************************************************************
appserver                  : ok=10   changed=7    unreachable=0    failed=0
dbserver                   : ok=4    changed=2    unreachable=0    failed=0
``` 

## Работа с community-ролями
 - Созданы файлы зависимостей для stage и prod
 - Добавлена зависимость на jdauphant.nginx
 - Через ansible-galaxy установлена роль
 - Роль jdauphant.nginx добавлена в .gitignore
 - Переменные для nginx добавлены в stage/group_vars/app и prod/group_vars/app 

## Самостоятельное задание
 - Добавил создание правила для 80 порта в Terrafrom
```
resource "google_compute_firewall" "firewall_nginx" {
  name    = "allow-nginx-default"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["80"]
  }

  source_ranges = "${var.firewall_source_ranges}"
  target_tags   = "${var.firewall_tags}"
}
```
 - Добавил вызов jdauphant.nginx в app.yml
```
  roles:
    - app
    - jdauphant.nginx
```
 - Запустил плейбук и убедился в доступности приложения на 80 порту

## Работа с Ansbile Vault

- Создал файл-ключ для ansible-vault
- Добавил путь до файла-ключа в конфиг ansible.cfg
- Добавил плейбук для создания пользователей ansible/playbooks/users.yml
- Добавил данные пользователей в ansible/environments/stage/credentials.yml и ansible/environments/prod/credentials.yml
- Зашифровал credentials.yml через ansible-vault encrypt
- Выполнили ansible-playbook site.yml
- Проверил что пользователи создались
```
admin:x:1002:100::/home/admin:
qauser:x:1003:1003::/home/qauser:
```

## Задание со * - Работа с динамическим инветори

- Добавил gce.py в директорию для каждого окружения
- Запустил из корня директории ansible-playbook -i environments/stage/gce.py playbooks/site.yml
- Обнаружил, что переменные в group_vars игнорируются при запуске плейбука через инветори-скрипт
- С огромным трудом догадался, что это происходит по причине того, что название группы, которое возвращает инвентори скрипт отличается от того, что используется в названии файла в group_vars. Методом научного тыка обнаружил, что возвращаемое значение имени группы - tag_app (по названию network tag, примененного к машине)
- Добавить в group_vars файлы tag_app и tag_db со значениями переменных для ролей.
- Запустил ansible-playbook -i environments/stage/gce.py playbooks/site.yml на чистой инфраструктуре, получился работоспособное приложение

## Задание с ** - Настройка Travis CI

- Добавил скрипт ./play-travis/hw12.sh содержащий в себе установку terrafrom6 packer, tflint, ansible-lint и запуску соответствующих проверок
- Отключил использование gce-bucket в роли backend чтобы не отображались сообщения о невозможности подключиться к bucket во время выполнения проверок
- Настроил запуск кастомной проверки только в случае коммита в мастер или пулл-реквеста
- Добавил badge из travis ci




