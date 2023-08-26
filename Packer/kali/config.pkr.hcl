packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type    = string
  default = "kali"
}

source "proxmox-iso" "kali" {
  proxmox_url              = "https://192.168.1.169:8006/api2/json"
  node                     = "proxmox"
  username                 = "root@pam!packer"
  token                    = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file                 = "local:iso/kali-linux-2023.1-live-amd64.iso"
  iso_checksum             = "sha256:b7c93ff333b6e3909a6e28de5408a916cbea2b5c2371e4b76ec12900d1158bc8"
  ssh_username             = "kali"
  ssh_password             = "asd15@#AB"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 4
  memory                   = 8192
  vm_name                  = "kali"
  qemu_agent               = true
  template_description     = "Kali"
  insecure_skip_tls_verify = true


  network_adapters {
    bridge = "vmbr1"
  }

  disks {
    disk_size    = "50G"
    storage_pool = "local"
  }
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",

    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kali.preseed ",
    "hostname=kali ",
    "auto=true ",
    "interface=auto ",
    "domain=vm ",

  ]
}

build {
  sources = ["sources.proxmox-iso.kali-black"]
}
