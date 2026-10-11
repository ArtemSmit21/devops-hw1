variable "vm_ip" {
  description = "Внешний IP виртуальной машины"
  type        = string
}

variable "ssh_user" {
  description = "Пользователь на VM, под которым Terraform управляет Docker"
  type        = string
  default     = "deployer"
}

variable "ssh_key_path" {
  description = "Путь к приватному SSH-ключу"
  type        = string
  default     = "/home/oss/.ssh/devops_key"
}

variable "nginx_port" {
  description = "Нестандартный внешний порт для nginx"
  type        = number
  default     = 8080
}
