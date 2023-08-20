packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "windows-10" {
  proxmox_url  = "https://192.168.1.169:8006/api2/json"
  node         = "proxmox"
  username     = "root@pam!packer"
  token        = "a279805f-c94d-4b69-83f5-8b715bfbb4c8"
  iso_file     = "local:iso/Win10_22H2_English_x64v1.iso"
  iso_checksum = "sha256:a6f470ca6d331eb353b815c043e327a347f594f37ff525f17764738fe812852e"
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
    iso_file     = "local:iso/windows-10-autounattend.iso"
    iso_checksum = "sha256:9506be70fddac41e436de683fbb6da618c2065e8beec2e162551d3c07d11fc1f"
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
    storage_pool      = "local"
  }
  scsi_controller = "virtio-scsi-pci"

}

build {
  sources = ["sources.proxmox-iso.windows-10"]
  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}
