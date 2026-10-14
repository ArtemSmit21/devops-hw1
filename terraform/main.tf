terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.vm_ip}:22"
  ssh_opts = [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-i", var.ssh_key_path,
  ]
}

resource "docker_network" "tf_net" {
  name = "tf_net"
}

resource "docker_volume" "nginx_html" {
  name = "nginx_html"
}

resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name    = "tf-nginx"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  lifecycle {
    ignore_changes = [network_mode]
  }

  networks_advanced {
    name = docker_network.tf_net.name
  }

  volumes {
    volume_name    = docker_volume.nginx_html.name
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = var.nginx_port
  }
}
