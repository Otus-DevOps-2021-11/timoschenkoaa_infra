variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
  default     = "~/.ssh/ubuntu.pub"
}
variable "subnet_id" {
  description = "Subnet"
  default     =  "e9b1ng7dq0d58a25ana4"
}
variable "service_account_key_file" {
  description = "key .json"
  default     = "./terraform_key.json"
}
variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "fd88ra742ri7j9uf9rng"
}