# A00999600,A00905457-
PORT="8080"
ADMIN_USER="admin"
TODOAPP_USER="todoapp"
DATABASE_FILE="/home/admin/acit4640/assignment1/setup/database.js"
NGINX_FILE="/home/admin/acit4640/assignment1/setup/nginx.conf"
SERVICE_FILE="/home/admin/acit4640/assignment1/setup/todoapp.service"
CONFIG_DIRECTORY="/home/todoapp/app/config"
NGINX_DIRECTORY="/etc/nginx"
SERVICE_DIRECTORY="/etc/systemd/system"
user_creation () {
	sudo useradd -p $(openssl passwd -1 P@ssw0rd) "$ADMIN_USER"
	sudo useradd -p $(openssl passwd -1 P@ssw0rd) "$TODOAPP_USER"
	sudo usermod -a -G wheel "$ADMIN_USER"
}

install () {

	sudo yum -y install git 
	sudo yum -y install mongodb-server 
	sudo yum -y install nodejs 
	sudo yum -y install npm
	sudo yum -y install psmisc	
	sudo yum -y install nginx
}
mongo() {
	sudo systemctl enable mongod
	sudo systemctl start mongod
	cd /home
}

port_forwarding() {
	sudo firewall-cmd --zone=public --add-port="$PORT"/tcp
	sudo firewall-cmd --zone=public --add-service=http
	sudo firewall-cmd --zone=public --add-service=ssh
	sudo firewall-cmd --zone=public --add-service=https
}

set_up_app() {
	sudo mkdir /home/todoapp/app
	sudo chmod 755 /home/todoapp
	sudo chmod 777 /home/todoapp/app
	git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app
	cd /home/todoapp
	sudo chown todoapp app
	cd /home/todoapp/app
	npm install
}


file_setup() {
	sudo cp -f "$DATABASE_FILE" "$CONFIG_DIRECTORY"
	sudo cp -f "$NGINX_FILE" "$NGINX_DIRECTORY"
	sudo cp -f "$SERVICE_FILE" "$SERVICE_DIRECTORY"
}

services_start() {
	sudo systemctl enable nginx
	sudo systemctl start nginx
	sudo systemctl daemon-reload
	sudo systemctl enable todoapp
	sudo systemctl start todoapp
}

server_start() {
	sudo killall node
	cd /home/todoapp/app
	node server.js
}

echo "starting script..."

user_creation
install
mongo
port_forwarding
set_up_app
file_setup
services_start
server_start