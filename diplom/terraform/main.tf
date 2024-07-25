terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = file("./key.json")
  cloud_id                 = "Your Yandex.Cloud cloud_id"
  folder_id                = "Your Yandex.Cloud folder_id"
  zone                     = "ru-central1-a"
}


#web1

resource "yandex_compute_instance" "web-vm1" {
  name     = "web-vm1"
  hostname = "web-vm1"
  zone     = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-1.id
    security_group_ids = [yandex_vpc_security_group.ssh-access-local.id, yandex_vpc_security_group.nginx-sg.id, yandex_vpc_security_group.filebeat-sg.id]
    ip_address         = "10.1.1.10"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}


#web2

resource "yandex_compute_instance" "web-vm2" {
  name     = "web-vm2"
  hostname = "web-vm2"
  zone     = "ru-central1-b"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-2.id
    security_group_ids = [yandex_vpc_security_group.ssh-access-local.id, yandex_vpc_security_group.nginx-sg.id, yandex_vpc_security_group.filebeat-sg.id]
    ip_address         = "10.2.1.20"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}


#zabbix-vm

resource "yandex_compute_instance" "zabbix-vm" {
  name     = "zabbix-vm"
  hostname = "zabbix-vm"
  zone     = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 4
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = "10"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-3.id
    security_group_ids = [yandex_vpc_security_group.ssh-access-local.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address         = "10.3.1.30"
    nat                = true
  }

  timeouts {
    create = "10m"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}


#elasticsearch-vm

resource "yandex_compute_instance" "elasticsearch-vm" {
  name     = "elasticsearch-vm"
  hostname = "elasticsearch-vm"
  zone     = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-3.id
    security_group_ids = [yandex_vpc_security_group.ssh-access-local.id, yandex_vpc_security_group.elasticsearch-sg.id, yandex_vpc_security_group.kibana-sg.id, yandex_vpc_security_group.filebeat-sg.id]
    ip_address         = "10.3.1.33"
  }

  timeouts {
    create = "10m"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}


#kibana-vm

resource "yandex_compute_instance" "kibana-vm" {
  name     = "kibana-vm"
  hostname = "kibana-vm"
  zone     = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.ssh-access-local.id, yandex_vpc_security_group.kibana-sg.id, yandex_vpc_security_group.elasticsearch-sg.id, yandex_vpc_security_group.filebeat-sg.id]
    ip_address         = "10.4.1.7"
    nat                = true
  }

  timeouts {
    create = "10m"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}


#BASTION

resource "yandex_compute_instance" "bastion-vm" {
  name     = "bastion-vm"
  hostname = "bastion-vm"
  zone     = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vljd295nqdaoogf3g"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.ssh-access.id, yandex_vpc_security_group.ssh-access-local.id]
    ip_address         = "10.4.1.40"
    nat                = true
  }

  timeouts {
    create = "10m"
  }

  metadata = {
    user-data = "${file("./meta.yml")}"
  }
}

#NETWORK

#основная сеть
resource "yandex_vpc_network" "network-diplom" {
  name = "network-diplom"
}

#подсеть для веб серивиса 1
resource "yandex_vpc_subnet" "private-1" {
  name           = "private-1"
  description    = "subnet-1"
  v4_cidr_blocks = ["10.1.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-diplom.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#подсеть для веб серивиса 2
resource "yandex_vpc_subnet" "private-2" {
  name           = "private-2"
  description    = "subnet-2"
  v4_cidr_blocks = ["10.2.1.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-diplom.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#подсеть для остальных сервисов
resource "yandex_vpc_subnet" "private-3" {
  name           = "private-3"
  description    = "subnet services"
  v4_cidr_blocks = ["10.3.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-diplom.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#публичная подсеть для бастиона, кибаны
resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  description    = "subnet bastion"
  v4_cidr_blocks = ["10.4.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-diplom.id
}

#настройка nat и статический маршрут через бастион для внутренней сети
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  network_id = yandex_vpc_network.network-diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}


#GROUP

#target group для балансировщика из двух сайтов с nginx
resource "yandex_alb_target_group" "tg-group" {
  name = "tg-group"

  target {
    ip_address = yandex_compute_instance.web-vm1.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.private-1.id
  }

  target {
    ip_address = yandex_compute_instance.web-vm2.network_interface.0.ip_address
    subnet_id  = yandex_vpc_subnet.private-2.id
  }

  /*depends_on = [
    yandex_compute_instance.web-vm1,
    yandex_compute_instance.web-vm2,
  ]*/
}

#backend Group
resource "yandex_alb_backend_group" "backend-group" {
  name = "backend-group"

  http_backend {
    name             = "backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.tg-group.id}"]
    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout             = "10s"
      interval            = "3s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

#security groups
resource "yandex_vpc_security_group" "ssh-access" {
  name       = "ssh-access"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.ssh-access-local.id
    port              = 22
  }
  egress {
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.ssh-access-local.id
  }
}

resource "yandex_vpc_security_group" "ssh-access-local" {
  name       = "ssh-access-local"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 22
  }
  egress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 22
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "nginx-sg" {
  name       = "nginx-sg"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "ANY"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "elasticsearch-sg" {
  name       = "elasticsearch-sg"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 9200
  }

  ingress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
  }

  egress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "yandex_vpc_security_group" "zabbix-sg" {
  name       = "zabbix-sg"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 10050
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 10051
  }

  egress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
  }

  egress {
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
  }
}


resource "yandex_vpc_security_group" "kibana-sg" {
  name       = "kibana-sg"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  egress {
    protocol       = "ANY"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "filebeat-sg" {
  name       = "filebeat_service"
  network_id = yandex_vpc_network.network-diplom.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
    port           = 5044
  }
  egress {
    protocol       = "TCP"
    port           = 5044
    v4_cidr_blocks = ["10.1.1.0/24", "10.2.1.0/24", "10.3.1.0/24", "10.4.1.0/24"]
  }
}

#sg-balancer

resource "yandex_vpc_security_group" "balancer-sg" {
  name       = "balancer-sg"
  network_id = yandex_vpc_network.network-diplom.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }
}


#ROUTER

resource "yandex_alb_http_router" "router" {
  name = "router"
}

resource "yandex_alb_virtual_host" "router-host" {
  name           = "router-host"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}


#BALANSER

resource "yandex_alb_load_balancer" "load-balancer" {
  name               = "load-balancer"
  network_id         = yandex_vpc_network.network-diplom.id
  security_group_ids = [yandex_vpc_security_group.balancer-sg.id]
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private-1.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.private-2.id
    }
  }

  listener {
    name = "listener-1"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}


#OUTPUT

#web-1
output "webserver-1" {
  value = yandex_compute_instance.web-vm1.network_interface.0.ip_address
}

#web-2
output "webserver-2" {
  value = yandex_compute_instance.web-vm2.network_interface.0.ip_address
}

#load_balancer
output "load_balancer_pub" {
  value = yandex_alb_load_balancer.load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address
}

#bastion
output "bastion_nat" {
  value = yandex_compute_instance.bastion-vm.network_interface.0.nat_ip_address
}
output "bastion" {
  value = yandex_compute_instance.bastion-vm.network_interface.0.ip_address
}

#kibana
output "kibana-nat" {
  value = yandex_compute_instance.kibana-vm.network_interface.0.nat_ip_address
}
output "kibana" {
  value = yandex_compute_instance.kibana-vm.network_interface.0.ip_address
}

#zabbix
output "zabbix_nat" {
  value = yandex_compute_instance.zabbix-vm.network_interface.0.nat_ip_address
}
output "zabbix" {
  value = yandex_compute_instance.zabbix-vm.network_interface.0.ip_address
}

#elasticsearch
output "elasticsearch-vm" {
  value = yandex_compute_instance.elasticsearch-vm.network_interface.0.ip_address
}