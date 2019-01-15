# DarkArren_infra
DarkArren Infra repository

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

testapp_IP = 35.246.169.74
testapp_port = 9292