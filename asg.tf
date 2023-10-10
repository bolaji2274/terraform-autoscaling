resource "aws_launch_configuration" "web_server" {
  image_id      = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  #   security_groups = [aws_security_group.server_sg.id]
  security_groups = [aws_security_group.alb.id]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

}

resource "aws_autoscaling_group" "web_server" {
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value               = "Server"
    propagate_at_launch = true
  }

  # Require when creating using a launch configuration with autoscaling group
  lifecycle {
    create_before_destroy = true
  }
}
