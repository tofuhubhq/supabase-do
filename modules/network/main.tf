variable "do_access_token" {
  description = "Digital ocean access token"
  type        = string
}

variable "do_vpc_region" {
  description = "Digital ocean vpc region"
  type        = string
}

variable "do_domain" {
  description = "Digital ocean domain"
  type        = string
  default     = ""
}

variable "do_vpc_name" {
  description = "Digital ocean vpc"
  type        = string
  default     = ""
}

provider "digitalocean" {
  token = var.do_access_token
}

# Create the VPC. There is no need to assign it to the project,
# because VPCs are not project scoped.
#@tofuhub:protects->chirpstack_nodes
#@tofuhub:protects->mosquitto
#@tofuhub:protects->redis
#@tofuhub:protects->postgres
resource "digitalocean_vpc" "main" {
  name     = var.do_vpc_name
  region   = var.do_vpc_region
}

# Create the domain
resource "digitalocean_domain" "supabase_domain" {
  name = var.do_domain
  # ip   = "203.0.113.10"  # Optional: sets an A record for root domain
}

resource "digitalocean_reserved_ip" "supabase_ip" {
  region = var.do_vpc_region
}

output "domain_name" {
  value = digitalocean_domain.supabase_domain.name
}

output "domain_resource_id" {
  value = digitalocean_domain.supabase_domain.id
}

output "supabase_reserved_ip" {
  value = digitalocean_reserved_ip.supabase_ip.ip_address
}
