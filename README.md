# DynamoDB
How to install DynamoDB on Linux using a Daemon

Download and install Java
sudo apt-get update
sudo apt-get install default-jre
Verify you can see the JRE
rick@ubuntu:~$ /usr/bin/java -version
openjdk version "1.8.0_151"
OpenJDK Runtime Environment (build 1.8.0_151-8u151-b12-0ubuntu0.16.04.2-b12)
OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)
Download Local DynamoDB to your machine and unzip them

mkdir DynamoDB
cd DynamoDB
wget https://s3-sa-east-1.amazonaws.com/dynamodb-local-sao-paulo/dynamodb_local_latest.tar.gz
tar -zxvf dynamodb_local_latest.tar.gz
rm dynamodb_local_latest.tar.gz
Create a deploy directory for the service daemon and move jar files over to the location

mkdir /opt/dynamodb
mv * /opt/dynamodb
cd /opt/dynamodb
mkdir /opt/dynamodb/data
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod -R g+w ./data
Create a user that will run the service

useradd dynamodb
chown -R dynamodb:dynamodb /opt/dynamodb
Create a Daemon
touch /etc/systemd/system/dynamodb.service
vim /etc/systemd/system/dynamodb.service
Daemon Sample
[Unit]
Description=DynamoDB on Localhost
After=network.target
Documentation=https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html

[Service]
Environment=deploydir=/opt/dynamodb
Type=simple
User=dynamodb
Group=dynamodb

ExecStart=/usr/bin/java -Djava.library.path=${deploydir}/DynamoDBLocal_lib -jar ${deploydir}/DynamoDBLocal.jar -sharedDb -dbPath ${deploydir}/data

[Install]
WantedBy=multi-user.target
Reload Daemon service
systemctl daemon-reload
Verify service is up
sudo systemctl stop dynamodb.service
sudo systemctl start dynamodb.service
sudo systemctl status dynamodb.service
Troubleshooting problems, when I was setting this up a couple of handy commands are the system logs and the ports that are being used.

netstat -ntlp | grep LISTEN
tail -f /var/log/system.log
That will do it, now everytime your machine startups, you will have DynamoDB service working in the background.
