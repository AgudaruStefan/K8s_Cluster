terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.6"
    }
}
}

data "terraform_remote_state" "network_details" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "disk_details" {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}

resource "libvirt_domain" "vm" {
    for_each = var.vm_vms_configs
    name = "${each.value.name}"
    memory = each.value.ram
    vcpu = each.value.cpu

    cloudinit = data.terraform_remote_state.disk_details.outputs["cloudinit_id"]["${each.key}"][each.value.index]


network_interface {
    network_name = "${data.terraform_remote_state.network_details.outputs.vm_network_name}"  
}

console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
}

console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
}

disk {
    volume_id = "${data.terraform_remote_state.disk_details.outputs["disk_id"]["${each.key}"][each.value.index]}"
}

graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
}
}