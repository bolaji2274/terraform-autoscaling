output "alb_dns_name" {
  value       = aws_lb.web_server.dns_name
  description = "The domain name of the load balancer"
}

# output "public_ip" {
#   value = aws_instance.web-server.public_ip
# }

# output "public_ip_asg" {
#   description = "The public ip  for all autoscalng instance"
#   value = aws_autoscaling_group.web-server.public_ip
# }