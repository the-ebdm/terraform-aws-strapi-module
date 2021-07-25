output "key" {
    value = aws_iam_access_key.storage.id
    sensitive = true
}

output "secret" {
    value = aws_iam_access_key.storage.secret
    sensitive = true
}

output "address" {
    value = "https://${var.domain}"
}

output "bucket" {
    value = aws_s3_bucket.storage
}

output "vpc" {
    value = module.vpc
}