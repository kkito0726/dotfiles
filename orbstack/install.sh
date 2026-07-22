sudo passwd ken
sudo apt-get update && sudo apt-get install -y --no-install-recommends git
sudo apt-get install -y -qq docker.io
sudo apt-get install docker-buildx

sudo usermod -aG docker ken
newgrp docker