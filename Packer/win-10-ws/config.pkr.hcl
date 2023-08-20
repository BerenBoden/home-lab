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
  default = "windows-10"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

source "proxmox-iso" "windows-10" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = "${var.proxmox_node}"
  username     = "root@pam!packer"
  token        = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file     = "local:iso/Win10_22H2_English_x64v1.iso"
  iso_checksum = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
  /*skip_export             = true*/
  communicator             = "ssh"
  ssh_username             = "windows-10"
  ssh_password             = "asd15@#AB"
  ssh_timeout              = "30m"
  qemu_agent               = true
  cores                    = 2
  memory                   = 4096
  vm_name                  = "windows-10"
  template_description     = "Base Seclab Windows Workstation"
  insecure_skip_tls_verify = true

  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-Win-10.iso"
    iso_checksum = "sha256:2893ca8f6d1f420436b6c213fa618710e7689a67d4bf924263361f07cced3b34"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:8a066741ef79d3fb66e536fb6f010ad91269364bd9b8c1ad7f2f5655caf8acd8"
    unmount      = true
  }

  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type              = "virtio"
    disk_size         = "50G"
    storage_pool      = "local-lvm"
  }
  scsi_controller = "virtio-scsi-pci"

}

build {
  sources = ["sources.proxmox-iso.windows-10"]
  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}
