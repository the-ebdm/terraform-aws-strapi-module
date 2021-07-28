terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.15.0"
    }
  }
}

data "archive_file" "source" {
  type        = "zip"
  output_path = "source.zip"
  excludes = [
    "source.zip",
    "node_modules",
    "main.tf",
    "network.tf",
    "loadbalancer.tf",
    "cert.tf",
    ".git",
    ".editorconfig",
    ".eslintrc",
    ".eslintignore",
    ".gitignore",
    ".terraform.locl.hcl",
    ".terraform.tfstate.lock.info",
    "terraform.tfstate",
    "terraform.tfstate.backup"
  ]

  source_dir = path.cwd
}

module "cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = var.domain
  zone_id     = var.zone_id
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.id}-strapi-storage"
  acl    = "private"

  tags = {
    System = "strapi"
    Subsystem = "storage"
    Client = var.id
  }

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
    ]
    allowed_origins = [
      "*",
    ]
    expose_headers  = []
    max_age_seconds = 0
  }
}

resource "aws_s3_bucket" "transfer" {
  bucket = "${var.id}-strapi-transfer"
  acl    = "private"

  tags = {
    System = "strapi"
    Subsystem = "transfer"
    Client = var.id
  }
}

resource "aws_s3_bucket" "backup" {
  bucket = "${var.id}-strapi-transfer"
  acl    = "private"

  tags = {
    System = "strapi"
    Subsystem = "backup"
    Client = var.id
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.storage.bucket
  key    = "strapi-source.zip"
  source = "source.zip"

  etag = data.archive_file.source.output_md5
}