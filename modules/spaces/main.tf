variable "do_access_token" {
  description = "DigitalOcean access token"
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

provider "aws" {
  alias  = "spaces"
  region = var.spaces_region
  access_key = var.spaces_access_key
  secret_key = var.spaces_secret_key

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    s3 = "https://${var.spaces_region}.digitaloceanspaces.com"
  }
}

resource "aws_s3_bucket" "supabase_space" {
  provider = aws.spaces
  bucket   = var.spaces_bucket_name
  
  tags = {
    Project = "Supabase"
    Purpose = "Static files / backups / assets"
  }
}

output "spaces_bucket_url" {
  value = "https://${aws_s3_bucket.supabase_space.bucket}.s3.${var.spaces_region}.digitaloceanspaces.com"
}