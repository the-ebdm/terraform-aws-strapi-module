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
}

resource "aws_s3_bucket_object" "object" {
  bucket = "franscape-data-archive"
  key    = "strapi-${var.id}.zip"
  source = "source.zip"

  etag = data.archive_file.source.output_md5
}