variable "do_access_token" {
  description = "DigitalOcean access token"
  type        = string
}

variable "do_project_id" {
  description = "DigitalOcean project ID"
  type        = string
}

variable "do_supabase_region" {
  description = "DigitalOcean region for the Supabase droplet"
  type        = string
}

variable "do_supabase_image" {
  description = "DigitalOcean image for Supabase droplet"
  type        = string
}

variable "do_supabase_size" {
  description = "DigitalOcean droplet size for Supabase"
  type        = string
}

variable "private_key_path" {
  description = "Path to your private SSH key"
  type        = string
}

variable "do_ssh_key_name" {
  description = "SSH key name"
  type        = string
}

variable "do_domain" {
  description = "DigitalOcean domain name"
  type        = string
  default     = ""
}

data "digitalocean_ssh_key" "my_key" {
  name = var.do_ssh_key_name
}

provider "digitalocean" {
  token = var.do_access_token
}

resource "digitalocean_droplet" "supabase" {
  name     = "supabase-droplet"
  region   = var.do_supabase_region
  size     = var.do_supabase_size
  image    = var.do_supabase_image
  ssh_keys = [data.digitalocean_ssh_key.my_key.id]
  tags     = ["supabase", "ssh"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = self.ipv4_address
  }

  # You can replace these inline commands with actual Supabase provisioning
  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update -y",
      "apt install -y docker.io docker-compose",
      "systemctl enable docker",
      "systemctl start docker"
      # Add your Supabase setup here if needed
    ]
  }
}

resource "digitalocean_project_resources" "assign_supabase_droplet" {
  project   = var.do_project_id
  resources = [digitalocean_droplet.supabase.urn]
}

resource "digitalocean_record" "supabase_dns" {
  domain = var.do_domain
  type   = "A"
  name   = "supabase"
  value  = digitalocean_droplet.supabase.ipv4_address
}

resource "digitalocean_firewall" "supabase_fw" {
  name = "supabase-firewall"
  tags = ["supabase"]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol             = "tcp"
    port_range           = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol             = "udp"
    port_range           = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "supabase_host" {
  value = digitalocean_droplet.supabase.ipv4_address
}

output "supabase_https_port" {
  value = 443
}
