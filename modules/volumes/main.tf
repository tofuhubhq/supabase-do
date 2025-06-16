variable "do_access_token" {
  description = "Digital ocean access token"
  type        = string
}

variable "do_project_name" {
  description = "Name of the DigitalOcean project"
  default     = "supabase"
}

variable "do_project_id" {
  description = "Digital ocean project id"
  type        = string
}

variable "do_project_description" {
  description = "Description of the project"
  default     = "Project for Supabase stack deployments"
}

variable "region" {
  description = "Region where resources will be created"
  default     = "fra1"
}

variable "volume_name" {
  description = "Name of the block storage volume"
  default     = "supabase-volume"
}

variable "volume_description" {
  description = "Description of the block storage volume"
  default     = "Block storage for Supabase project"
}

variable "volume_size_gb" {
  description = "Size of the volume in GB"
  default     = 100
}

variable "volume_filesystem_type" {
  description = "Filesystem type for the volume"
  default     = "ext4"
}

variable "volume_label" {
  description = "Filesystem label for the volume"
  default     = "supabase-data"
}

provider "digitalocean" {
  token = var.do_access_token
}

resource "digitalocean_volume" "supabase_volume" {
  name                    = var.volume_name
  region                  = var.region
  size                    = var.volume_size_gb
  description             = var.volume_description
  initial_filesystem_label = var.volume_label
}

resource "digitalocean_project_resources" "project_resources" {
  project   = var.do_project_id
  resources = [digitalocean_volume.supabase_volume.urn]
}

output "volume_id" {
  value = digitalocean_volume.supabase_volume.id
}