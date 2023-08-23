packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

variable "proxmox_api_id" {
  type    = string
  default = "root@pam!packer"
}

variable "proxmox_api_token" {
  type    = string
  default = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
}

source "proxmox-iso" "ubuntu-server" {
  proxmox_url              = "https://192.168.1.169:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${var.proxmox_api_id}"
  token                    = "${var.proxmox_api_token}"
  iso_file                 = "local:iso/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum             = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  ssh_username             = "ubuntu-server"
  ssh_password             = "asd15@#AB"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 2
  memory                   = 8192
  vm_name                  = "ubuntu-server"
  vm_id                    = "110"
  qemu_agent               = true
  template_description     = "Ubuntu 22.04 Server"
  insecure_skip_tls_verify = true
    # VM Cloud-Init Settings
  cloud_init = true
  cloud_init_storage_pool = "local"

  network_adapters {
    bridge = "vmbr1"
  }
  disks {
    disk_size    = "30G"
    storage_pool = "local"
  }
  
  boot_command = [
      "<esc><wait>",
      "e<wait>",
      "<down><down><down><end>",
      "<bs><bs><bs><bs><wait>",
      "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
      "<f10><wait>"
  ]
  boot = "c"
  boot_wait = "5s"

}

build {
  name = "ubuntu-server"
  sources = ["sources.proxmox-iso.ubuntu-server"]
  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
