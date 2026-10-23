variable "ssh_private_key_path" {
  description = "Path to the SSH private key for nixos-anywhere"
  type        = string
  default     = "/home/serralq/.ssh/id_ed25519"
}
