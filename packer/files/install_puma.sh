#!/bin/bash
apt-get install -y git
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
echo "[Unit]" >> service
echo "Description=Puma" >> service
echo " " >> service
echo "[Service]" >> service
echo "ExecStart=/usr/local/bin/puma -C /home/ubuntu/reddit/config/deploy/production.rb --pidfile /home/ubuntu/reddit/puma.pid -e production" >> service
echo "WorkingDirectory=/home/ubuntu/reddit" >> service
echo "Restart=always" >> service
echo "KillMode=process" >> service
echo " " >> service
echo "[Install]" >> service
echo "WantedBy=multi-user.target" >> service
touch /etc/systemd/system/puma.service
cat service > /etc/systemd/system/puma.service
chmod 664 /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl start puma
systemctl enable puma