



# Pi Node Installation

## Raspberry Pi OS Image



username : node

password : greenglass



## Install Packages

```shell
sudo apt update
sudo apt upgrade

sudo apt install openjdk-17-jdk -y
sudo apt install pigpiod

sudo raspi-config -> enable i2c
sudo raspi-config -> enable  serial
```

## Create Startup Script

```shell
#!/bin/sh
export CONFIG_DIRECTORY="/home/node/hydroponics-node-0.0.2/config"
export WEB_DIRECTORY="/home/node/hydroponics-node-0.0.2/web"
/home/node/hydroponics-node-0.0.2/bin/hydroponics-node $CONFIG_DIRECTORY $WEB_DIRECTORY
```

## Create Service and set to autostart

/lib/systemd/system/node.service

```toml
[Unit]
Description=Greenglass node
After=multi-user.target

[Service]
ExecStart=sudo /home/node/node.sh
User=node
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=node


[Install]
WantedBy=multi-user.target
```



Redirect output to syslog but keep separate log file in /home/node/log/node.log

Create /etc/rsyslog.d/node.conf

```shell
if $programname == 'node' then /home/node/log/node.log
& stop
```

Create the log file, change its permissions and restart syslog

```
touch /home/node/log/node.log
sudo chown root:adm /home/node/log/node.log
sudo systemctl restart rsyslog
```

```
sudo systemctl daemon-reload
sudo systemctl enable node.service 
```



## Configure the Node Settings

Open the settings web page

```
http://<host-name>:8181
```



![Screenshot 2024-03-31 at 12.50.25](../../../../Library/Application Support/typora-user-images/Screenshot 2024-03-31 at 12.50.25.png)
