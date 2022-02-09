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

# ДЗ№8 Практика IaC с использованием Terraform

## Создаем сервисный аккаунт
https://cloud.yandex.ru/docs/iam/quickstart-sa
https://cloud.yandex.com/en-ru/docs/iam/operations/iam-token/create-for-sa#keys-create

## Запускаем создание ВМ через terraform
terraform apply -auto-approve
Ошибка при выполнении: E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
Решение здесь - https://askubuntu.com/questions/1109982/e-could-not-get-lock-var-lib-dpkg-lock-frontend-open-11-resource-temporari
sudo rm /var/lib/dpkg/lock*
## Задание с **
создаем балансировщик и таргет группу
```
resource "yandex_lb_target_group" "loadbalancer" {
  name      = "lb-group"
  folder_id = var.folder_id
  region_id = var.region_id

  dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }
}


resource "yandex_lb_network_load_balancer" "lb" {
  name = "loadbalancer"
  type = "external"

  listener {
    name        = "reddit-apps"
    port        = 80
    target_port = 9292

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.loadbalancer.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 9292
      }
    }
  }
}
```
Добавляем вторую ноду с приложением и подключаем к балансировщику.
Неудобно, т.к. много правок в разных файлах!
Добавлен параметр count (значение задаем через переменную)
