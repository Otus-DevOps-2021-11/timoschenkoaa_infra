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
<<<<<<< HEAD
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

# Домашнее задание 2 по Terraform

добавлены образы packer для app и db
конфигурация terraform разбита на модули
с использованием модулей сделаны конфигурации окружений stage и prod
создан backet

```
provider "yandex" {
  service_account_key_file = "var.service-account-key-file"
  cloud_id                 = "var.cloud-id"
  folder_id                = "var.folder-id"
  zone                     = "var.zone-id"
}

resource "yandex_storage_bucket" "otus-storage-bucket" {
  bucket        = "bucket-name"
  access_key    = "access-key"
  secret_key    = "secret-key"
  force_destroy = "true"
}
```

# ДЗ: "Управление конфигурацией. Знакомство с Ansible":
## Задание 1:
- Разобраны типовые Ad-Hoc команды;
- Написан базовый плейбук;
- Выполнена работа с различными типами Inventory-файлов;
- Создан статический инвентори в формате JSON

# ДЗ: Деплой и управление конфигурацией с Ansible

- Изучил хендлеры и шаблоны для конфигурации окружения и деплоя тестового приложения
- Написал плэйбуки для деплоя приложения, изменил провижинер для Packer

# ДЗ: Ansible: работа с ролями и окружениями

- На основе ранее созданных плэйбуков, создали роли app/db
- Развернул окружения stage/prod с использованием ansible roles
- Зашифровал данные с помощью ansible vault

# ДЗ: Разработка и тестирование Ansible ролей и плейбуков

## Выполненные работы
 
- Установка vagrant
- Описываем локальную инфраструктуру в Vagrantfile
- Дорабатываем роли и учимся использовать provisioner
- Переделываем deploy.yml
- Проверяем сборку в vagrant
- Устанавливаем pip, а затем с помощью его virtualenv
- Устанавливаем все необходимые пакеты pip install -r requirements.txt
- Создаем заготовку molecule с помощью команды molecule init scenario --scenario-name default -r db -d vagrant
- Добавляем собственнные тесты
- Собираем и тестируем нашу конфигурацию

## Самостоятельные задания:

Пишем тест для проверки доступности порта 27017:
```
# check 27017 port
def test_mongo_port(host):
    socket = host.socket('tcp://0.0.0.0:27017')
    assert socket.is_listening
```    
## Используем роли db и app в packer_db.yml и packer_app.yml
```
 "type": "ansible",
 "playbook_file": "ansible/playbooks/packer_db.yml",
 "extra_arguments": ["--tags","install"],
 "ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]
```
```
"type": "ansible",
"playbook_file": "ansible/playbooks/packer_app.yml",
"extra_arguments": ["--tags","ruby"],
"ansible_env_vars": ["ANSIBLE_ROLES_PATH={{ pwd }}/ansible/roles"]
```
