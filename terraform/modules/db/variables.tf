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
variable "db_disk_image" {
  description = "Disk image for reddit db"
  default     = "fd8ls5lmei6v57g6fbn5"
}