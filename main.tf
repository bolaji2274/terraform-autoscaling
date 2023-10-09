provider "aws" {
  region = "us-east-1"
}

# resource "aws_instance" "web-server" {
#   ami                         = "ami-0261755bbcb8c4a84"
#   instance_type               = "t2.micro"
#   vpc_security_group_ids      = [aws_security_group.server-sg.id]
#   user_data                   = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p ${var.server_port} &
#               EOF
#   user_data_replace_on_change = true
#   tags = {
#     Name = "Server"
#   }
# }

resource "aws_launch_configuration" "web_server" {
  image_id = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.server_sg.id]
  user_data                   = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

}

resource "aws_autoscaling_group" "web_server" {
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"

  min_size = 2
  max_size = 5

  tag {
    key = "Name"
    value = "Server"
    propagate_at_launch = true
  }

  # Require when creating using a launch configuration with autoscaling groupt
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "web_server" {
  name = "Server"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [ aws_security_group.alb.id ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name = "Server"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "alb" {
  name = "alb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]

    }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_security_group" "server_sg" {
  # vpc_id = aws.vpc_id
  name = "server-security"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port number for the server"
  # default = 8080
  type = number
}

# output "public_ip" {
#   value = aws_instance.web-server.public_ip
# }

# output "public_ip_asg" {
#   description = "The public ip  for all autoscalng instance"
#   value = aws_autoscaling_group.web-server.public_ip
# }