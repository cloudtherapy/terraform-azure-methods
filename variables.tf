## Secure Variables
variable "vpn_passphrase" {
  description = "Azure connection (VPN) passphrase"
  sensitive   = true
  type        = string
}