packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "username" {
  type    = string
  default = "kde"
}

variable "password" {
  type    = string
  default = "seclab"
}

variable "hostname" {
    type    = string
    default = "ubuntu-server"
}

variable "proxmox_node" {
    type    = string
    default = "proxmox"
}


source "proxmox-iso" "ubuntu-server" {
  insecure_skip_tls_verify = true
  proxmox_url            = "https://192.168.1.169:8006/api2/json"
  node                   = "${var.proxmox_node}"
  token                  = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file               = "local:iso/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum           = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  username               = "root@pam!packer"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"+++
  cores                  = 2
  memory                 = 2048
  vm_name                = "ubuntu-server-22-04"
  qemu_agent             = true
  template_description   = "Seclab Ubuntu Server 22.04.2"

  network_adapters {
    bridge = "vmbr1"
  }

  disks {
    disk_size         = "30G"
    storage_pool_type = "lvm"
    storage_pool      =  "local"
  }
  boot_wait              = "10s"
  boot_command = [
    "<esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"
  ]
}

build {
  sources = ["source.proxmox-iso.ubuntu-server"]
  
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/ubuntu-server/${var.hostname}/g' /etc/hostname",
      "mkdir /home/seclab/.ssh",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZj/mKU/5/rygeoJY4Xpp48g0f6Wu/Iuj4NxIyiEk/fPZWqEMz0UkSI8qsj0RHIxAmUqDYZXrv52CeVpWC6OHqa6bmKtrm7IUustyIxck/MmCTbe8a2OZD7R1hdMVB3G82qZrYIdJ8jmrRle+DAcgt3fjGl2QKYizD0sTaJn1nIjobZq5VGYIDdOrFJ9GirXdcoo6bdepHsr7mcC+iVYW0kAjdXpcngtxRItov8P9f61NHX2FGnL/Lg5B/L5XzT2ucd1ditNRC/HMw0gxWfnhoS5OKrH3qNkWJO2dzd/cdjB74x2sJEVh/dbCRkJfPvBs5L2FSM7RmO6P8kWgYt9zcq4wFiAFB40hGiHhwed3MBa0F+U99WZZYsNF1yvWl/bHi5sPoEuMR8ka+iYHb1U17/hOOl6yrm94Au8Rll3yyj27NDF/ame5Nlg810HKpGKJYTJJqEHEusz2ZkY5+Rpb26FW1oT4XZI7I/1RgDwUVI/oh+xcdw2jr1dAWIYt2FR0= kde@seclab-kde-jumpbox' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/.ssh/authorized_keys"
    ]
  }
}
