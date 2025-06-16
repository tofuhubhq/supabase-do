terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_access_token" {
  description = "Digital ocean access token"
  type        = string
  default     = ""
}

variable "do_project_name" {
  description = "Digital ocean project name"
  type        = string
  default     = "Digital ocean project name"
}

variable "do_project_description" {
  description = "Digital ocean project description"
  type        = string
  default     = "Digital ocean project description"
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
  description = "Supabase vpc"
  type        = string
  default     = ""
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

resource "digitalocean_project" "supabase" {
  name        = var.do_project_name
  description = var.do_project_description
  purpose     = "Web Application"
  environment = "Development"

  # You can add resources to this project later with the 'resources' attribute
}

module "network" {
  source = "./modules/network"
  do_access_token = var.do_access_token
  do_vpc_region  = var.do_vpc_region
  do_domain = var.do_domain
  do_vpc_name = var.do_vpc_name
}

module "volume" {
  source = "./modules/volumes"
  do_access_token = var.do_access_token
  do_project_id = digitalocean_project.supabase.id
  region = var.region
  volume_name = var.volume_name
  volume_description = var.volume_description
  volume_size_gb = var.volume_size_gb
  volume_filesystem_type = var.volume_filesystem_type
  volume_label = var.volume_label
}