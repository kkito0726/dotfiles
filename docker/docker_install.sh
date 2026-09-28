sudo apt update && sudo apt upgrade -y
sudo apt install -y curl

# dockerのインストールスクリプトをダウンロード
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

sudo service docker start

# 現在のユーザーを docker グループに追加します。
sudo usermod -aG docker $USER

rm get-docker.sh
