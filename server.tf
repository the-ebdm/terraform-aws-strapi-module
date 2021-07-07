data "aws_ami" "base_ami" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:ami"
    values = ["strapi-base"]
  }

  most_recent = true
  owners      = ["868476632230"]
}

resource "aws_instance" "instance" {
  depends_on                  = [aws_s3_bucket_object.object]
  ami                         = data.aws_ami.base_ami.id
  instance_type               = "t2.small"
  associate_public_ip_address = true
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${var.id}_strapi_server"
    Client = var.id
  }

  iam_instance_profile = "ec2-access-s3"

  user_data = <<EOF
#!/bin/bash
aws s3 cp s3://franscape-data-archive/strapi-${var.id}.zip /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/strapi-${var.id}.zip
unzip /home/ubuntu/strapi-${var.id}.zip -d /home/ubuntu/strapi
chown ubuntu:ubuntu -R /home/ubuntu/strapi

su ubuntu -c "cd ~/strapi && npm install && NODE_ENV=production npm run build"
su ubuntu -c "/home/ubuntu/.npm-global/bin/pm2 start ~/strapi/ecosystem.config.js"
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "api" {
  name            = "${var.id}-strapi-lb"
  internal        = false
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.lb_secgroup.id]

  tags = {
    Name = "strapi_api_alb"
    Client = var.id
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.cert.this_acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.id}-strapi-api"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.instance.id
  port             = 1337

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "server" {
  name            = "server.${var.id}.strapi.franscape.io"
  type            = "A"
  zone_id         = "Z09936565SB6P6INZE3R"
  ttl             = 60
  records         = [aws_instance.instance.public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "api" {
  name            = "${var.id}.strapi.franscape.io"
  type            = "CNAME"
  zone_id         = "Z09936565SB6P6INZE3R"
  ttl             = 60
  records         = [aws_lb.api.dns_name]
  allow_overwrite = true
}