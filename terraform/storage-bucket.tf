resource "yandex_storage_bucket" "otus-storage-bucket" {
  bucket        = "bucket-name"
  access_key    = "access-key"
  secret_key    = "secret-key"
  force_destroy = "true"
}
