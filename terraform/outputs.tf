output "nginx_url" {
  description = "Адрес nginx снаружи"
  value       = "http://${var.vm_ip}:${var.nginx_port}"
}
