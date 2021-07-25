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

resource "aws_iam_role" "node" {
  name = "${var.id}-node-bucket-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Create AWS IAM instance profile
# Attach the role to the instance profile
resource "aws_iam_instance_profile" "node" {
  name = "${aws_iam_role.node.name}-profile"
  role = aws_iam_role.node.name
}

# Create a policy for the role
resource "aws_iam_policy" "node" {
  name        = var.ec2_iam_role_name
  path        = "/"
  description = var.policy_description
  policy      = <<EOF
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

# Attaches the policy to the IAM role
resource "aws_iam_policy_attachment" "node" {
  name       = var.ec2_iam_role_name
  roles      = [aws_iam_role.node.name]
  policy_arn = aws_iam_policy.node.arn
}