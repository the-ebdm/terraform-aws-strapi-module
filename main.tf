data "aws_route53_zone" "franscape" {
  name         = "franscape.io"
  private_zone = false
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

  source_dir = path.module
}

module "cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = "${var.id}.strapi.franscape.io"
  zone_id     = data.aws_route53_zone.franscape.zone_id
}

resource "aws_s3_bucket_object" "object" {
  bucket = "franscape-data-archive"
  key    = "strapi.zip"
  source = "source.zip"

  etag = data.archive_file.source.output_md5
}