rm -f .env
touch .env
echo "UID=$(id -u $USER)" >> .env
echo "GID=$(id -g $USER)" >> .env
echo "UNAME=$USER" >> .env
echo "SCREEN_RESOLUTION=1920x1800x24" >> .env
echo "HOST_IP=$(hostname -I | cut -f1 -d' ')" >> .env
echo "DISPLAY=:3" >> .env

docker-compose -p $USER -f docker-compose.yml up