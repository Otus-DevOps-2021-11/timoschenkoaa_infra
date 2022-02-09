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
