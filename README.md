# timoschenkoaa_infra
timoschenkoaa Infra repository

# ДЗ№7 Модели управления инфраструктурой. Подготовка образов с помощью Packer

## Запуск сборки образа:

"folder_id": "b1gsctj8bhd7q8md5uf1"

! Ошибка - Failed to find instance ip address: instance has no one IPv4 external address Решение:
"use_ipv4_nat": true

## Параметризирование шаблона

packer.io build -var-file=./variables.json ./ubuntu16.json
Пример variables.json
```
{
    "service_account_key_file": "key.json",
    "folder_id": "b1gsctj8bhd7q8md5uf1",
    "source_image_family": "ubuntu-1604-lts"
}
```

## Построение bake-образа

Создал install_puma.sh, добавил в провижинер bake образа
### install_puma.sh:
```
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
```

 ### Bake образ:
 ```
{   
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{ user `service_account_key_file` }}",
            "folder_id": "{{ user `folder_id` }}",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "reddit-full-{{timestamp}}",
            "image_family": "reddit-full",
            "ssh_username": "ubuntu",
            "platform_id": "{{ user `platform_id` }}",
            "disk_size_gb": "10",
            "use_ipv4_nat": "true"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}",
            "pause_before": "60s"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "files/install_puma.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
