terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  default     = "~/.ssh/id_rsa"
}

variable "do_ssh_key_name" {
  description = "SSH key name"
  type        = string
}

variable "spaces_access_key" {
  description = "Spaces access key (S3-compatible)"
  type        = string
}

variable "spaces_secret_key" {
  description = "Spaces secret key (S3-compatible)"
  type        = string
}

variable "spaces_region" {
  description = "Spaces region (e.g., 'fra1', 'nyc3')"
  type        = string
  default     = "fra1"
}

variable "spaces_bucket_name" {
  description = "Name of the Spaces bucket"
  type        = string
  default     = "supabase-assets"
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

module "supabase" {
  source = "./modules/droplet"
  do_access_token = var.do_access_token
  do_project_id = digitalocean_project.supabase.id
  do_supabase_size = var.do_supabase_size
  private_key_path = var.private_key_path
  do_supabase_image = var.do_supabase_image
  do_ssh_key_name = var.do_ssh_key_name
  do_supabase_region = var.region
  do_domain = var.do_domain
}

module "spaces" {
  source = "./modules/spaces"
  do_access_token = var.do_access_token
  spaces_access_key = var.spaces_access_key
  spaces_bucket_name = var.spaces_bucket_name
  spaces_region = var.region
  spaces_secret_key = var.spaces_secret_key
}