resource "aws_iam_user" "storage" {
  name = "${var.id}_strapi"
}

resource "aws_iam_access_key" "storage" {
  user = aws_iam_user.storage.name
}

resource "aws_iam_user_policy" "storage" {
  name = "${var.id}_strapi_storage_policy"
  user = aws_iam_user.storage.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.storage.arn}/*"
    },
    {
      "Action": ["ses:*"],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}