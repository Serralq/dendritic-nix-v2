terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

variable "hostname" {
  description = "Hostname for the NixOS server (must match the flake output)"
  type        = string
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
}

variable "ssh_key_id" {
  description = "Hetzner SSH key ID"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for nixos-anywhere"
  type        = string
}

variable "flake_root" {
  description = "Path to the flake root directory"
  type        = string
}

resource "hcloud_server" "this" {
  name        = var.hostname
  server_type = var.server_type
  location    = var.location
  image       = "ubuntu-24.04"

  ssh_keys = [var.ssh_key_id]

  labels = {
    managed = "opentofu"
  }

  provisioner "remote-exec" {
    inline = ["echo 'SSH ready'"]

    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file(var.ssh_private_key_path)
      timeout     = "5m"
    }
  }
}

resource "null_resource" "nixos_anywhere" {
  triggers = {
    server_id = hcloud_server.this.id
  }

  provisioner "local-exec" {
    command = "nix run github:nix-community/nixos-anywhere -- --flake ${var.flake_root}#${var.hostname} --build-on remote root@${hcloud_server.this.ipv4_address}"
  }

  depends_on = [hcloud_server.this]
}

output "ipv4_address" {
  value = hcloud_server.this.ipv4_address
}

output "ipv6_address" {
  value = hcloud_server.this.ipv6_address
}
