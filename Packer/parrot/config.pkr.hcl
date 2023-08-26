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

source "proxmox-iso" "parrot-security" {
  proxmox_url              = "https://192.168.1.169:8006/api2/json"
  node                     = "proxmox"
  username                 = "root@pam!packer"
  token                    = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file                 = "local:iso/Parrot-security-5.3_amd64.iso"
  iso_checksum             = "sha256:e0db9859a847b7a667e3b01a32e751ba56e4bd0321c3ad125ec9ef18ed21cba9"
  ssh_username             = "parrot-security"
  ssh_password             = "asd15@#AB"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 4
  memory                   = 8192
  vm_name                  = "parrot-security"
  qemu_agent               = true
  template_description     = "Parrot"
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
    "install <wait>",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "auto <wait>",
    "locale=en_US.UTF-8 <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "netcfg/get_hostname={{ .Name }} <wait>",
    "netcfg/get_domain=vagrantup.com <wait>",
    "fb=false <wait>",
    "debconf/frontend=noninteractive <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "grub-installer/bootdev=/dev/sda <wait>",
    "<enter><wait>"
  ]
}

build {
  sources = ["sources.proxmox-iso.parrot-security"]
}
