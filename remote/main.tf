data "hcloud_ssh_key" "default" {
  name = "alexanderngocdao@gmail.com"
}

module "otaru" {
  source = "./modules/hetzner-nixos"

  hostname             = "otaru"
  server_type          = "cx23"
  location             = "nbg1"
  ssh_key_id           = data.hcloud_ssh_key.default.id
  ssh_private_key_path = var.ssh_private_key_path
  flake_root           = "${path.root}/.."
}

module "choshi" {
  source = "./modules/hetzner-nixos"

  hostname             = "choshi"
  server_type          = "cx33"
  location             = "hel1"
  ssh_key_id           = data.hcloud_ssh_key.default.id
  ssh_private_key_path = var.ssh_private_key_path
  flake_root           = "${path.root}/.."
}
