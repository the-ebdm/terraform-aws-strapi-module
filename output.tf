output "key" {
    value = aws_iam_access_key.storage.id
    sensitive = true
}

output "secret" {
    value = aws_iam_access_key.storage.secret
    sensitive = true
}

output "address" {
    value = "https://${var.id}.strapi.franscape.io"
}

output "bucket" {
    value = aws_s3_bucket.storage
}