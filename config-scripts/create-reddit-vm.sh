gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family reddit-full \
  --machine-type=g1-small \
  --zone=europe-west3-c \
  --restart-on-failure \
  --tags puma-server

