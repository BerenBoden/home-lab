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
  default = "kali-black"
}

source "proxmox-iso" "kali-black" {
  proxmox_url              = "https://192.168.1.169:8006/api2/json"
  node                     = "proxmox"
  username                 = "root@pam!packer"
  token                    = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file                 = "local:iso/kali-linux-2020.2-installer-amd64.iso"
  iso_checksum             = "sha256:ae9a3b6a1e016cd464ca31ef5055506cecfc55a10f61bf1acb8313eddbe12ad7"
  ssh_username             = "kali-black"
  ssh_password             = "asd15@#AB"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 4
  memory                   = 8192
  vm_name                  = "kali-black"
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
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "/install.amd/vmlinuz noapic ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kali.preseed ",
    "hostname=kali ",
    "auto=true ",
    "interface=auto ",
    "domain=vm ",
    "initrd=/install.amd/initrd.gz -- <enter>"
  ]
}

build {
  sources = ["sources.proxmox-iso.kali-black"]
}
