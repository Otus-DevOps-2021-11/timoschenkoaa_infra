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
