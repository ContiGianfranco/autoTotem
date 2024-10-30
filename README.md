NOTA: el modo kiosk no funciona en Raspy si no se tiene un monitor conectado

1. Instalar raspberry pi OS:

ssh Totem001@172.16.130.125

host: totem###
user: Totem###
password: RKN###

2. Actualizar con:

$ sudo apt update
$ sudo apt upgrade

y responderle que yes, que quiero actualizar todo


3. En simbolo de sistema -> preferences -> raspberry pi configuration , en la pestaña interfaces habilitar vnc.
   Alternativamente puede configurarse a través de consola

$ sudo raspi-config

Interface Options > VNC > Yes

4. Instalar dependencias:

$ sudo apt-get install matchbox-window-manager xautomation unclutter

4. Crear un script .kiosk en el home, con lo siguiente adentro:

#!/bin/sh
xset -dpms     # disable DPMS (Energy Star) features.
xset s off     # disable screen saver
xset s noblank # don't blank the video device
matchbox-window-manager -use_titlebar no &
unclutter &    # hide X mouse cursor unless mouse activated
chromium-browser --display=:0 --kiosk --incognito --window-position=0,0 https://reelyactive.github.io/diy/pi-kiosk/

5. hacerlo ejecutable con:

$ chmod 755 ~/kiosk

6 editar el archivo ~/.bashrc y agregar esto a lo ultimo:

$ xinit /home/{$pi}/kiosk -- vt$(fgconsole)

reemplazar {$pi} por Totem###

7. Montar servidor web

$ sudo apt update
$ sudo apt install lighttpd -y
$ sudo systemctl enable lighttpd
$ sudo systemctl start lighttpd

Con eso debería andar, se necesita crear un index.html para mostrar de prueba, en /var/www/html
quizas se necesiten cambiar algunos permisos de acceso en caso de 403 forbidden

8. crear carpeta scripts en /home:

$ sudo mkdir /home/scripts

cambiarle los permisos adecuadamente segun totem

$ sudo chown Totem001:Totem001 /home/scripts

listo, acá vamos a meter todos los scripts

9. Dentro de scripts creamos la carpeta envs para ir creando environments:
   y dentro de la misma , la carpeta modbus:

$ mkdir /home/scripts/envs
$ mkdir /home/scripts/envs/modbus

dentro de la carpeta modbus:

$ python3 -m venv sensor-env
$ source sensor-env/bin/activate

luego:

$ pip install minimalmodbus aiomysql asyncio

eso instalará algunas dependencias,

$ pip install pyserial

por si las dudas, pero ya viene con minimalmodbus,

El puerto /dev/ttyUSB0 suele estar restringido a usuarios root. Para permitir que el usuario Totem001 lo use sin sudo:

sudo usermod -aG dialout $(whoami)

por si las dudas, aunque ya viene por defecto.

10. instalar y configurar mysql:

sudo apt install mariadb-server -y

para iniciar el servicio y asegurarnos que se ejecute cuando inicie la raspi

sudo systemctl start mariadb
sudo systemctl enable mariadb

para volver segura la instalacion:

sudo mysql_secure_installation

responder adecuadamente:

OTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] n
... skipping.

By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
- Dropping test database...
  ... Success!
- Removing privileges on test database...
  ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!

bueno eso.

11. sudo chown Totem001:Totem001 /var/www/html/ para poder copiar la pagina que mandó fer

12. vamos a entrarle a la db aa crear cositas de testeo:

sudo mysql -u root -p

una vez adentro:

CREATE DATABASE sensor_data;
CREATE USER 'sensor_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON sensor_data.* TO 'sensor_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

luego:

sudo mysql -u root -p

para entrarle nuevamente,
y ahí si, creamos tabla:

USE sensor_data;

CREATE TABLE sensor_data (
id INT AUTO_INCREMENT PRIMARY KEY,
device_id INT NOT NULL,
float_1 FLOAT,
float_2 FLOAT,
float_3 FLOAT,
float_4 FLOAT,
float_5 FLOAT,
timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EXIT;

13. que te parece

14. probar el script

Sys Opt > Boot > Desktop Autologin

scp .\Downloads\zidane.jpg Totem001@totem001.local:~/