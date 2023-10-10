
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

# resource "aws_security_group" "server_sg" {
#   # vpc_id = aws.vpc_id
#  vpc_id = data.aws_vpc.default.id
#   name = "server-security"

#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }