output "otaru_ipv4" {
  description = "Public IPv4 address of the otaru server"
  value       = module.otaru.ipv4_address
}

output "otaru_ipv6" {
  description = "Public IPv6 address of the otaru server"
  value       = module.otaru.ipv6_address
}

output "choshi_ipv4" {
  description = "Public IPv4 address of the choshi server"
  value       = module.choshi.ipv4_address
}

output "choshi_ipv6" {
  description = "Public IPv6 address of the choshi server"
  value       = module.choshi.ipv6_address
}
