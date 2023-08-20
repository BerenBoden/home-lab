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
  default = "windows-server"
}

variable "proxmox_hostname" {
  type    = string
  default = "proxmox"
}


source "proxmox-iso" "windows-server" {
  proxmox_url              = "https://192.168.1.169:8006/api2/json"
  node                     = "proxmox"
  username                 = "root@pam!packer"
  token                    = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file                 = "local:iso/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum             = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
  insecure_skip_tls_verify = true
  communicator             = "ssh"
  ssh_username             = "windows-server"
  ssh_password             = "asd15@#AB"
  ssh_timeout              = "30m"
  qemu_agent               = true
  cores                    = 2
  memory                   = 4096
  vm_name                  = "windows-server"
  template_description     = "Base Seclab Windows Server"

  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/windows-server-autounattend.iso"
    iso_checksum = "sha256:1f7cf806b809fbca6013caa6eb011f836b5227618c579fe9e48c08bc0aeff867"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio-win-0.1.229.iso"
    iso_checksum = "sha256:c88a0dde34605eaee6cf889f3e2a0c2af3caeb91b5df45a125ca4f701acbbbe0"
    unmount      = true
  }


  network_adapters {
    bridge = "vmbr1"
  }
    
  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type              = "virtio"
    disk_size         = "50G"
    storage_pool_type = "lvm"
    storage_pool      = "local"
  }
  scsi_controller = "virtio-scsi-pci"
}


build {
  sources = ["sources.proxmox-iso.windows-server"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig",
    ]
  }

}
