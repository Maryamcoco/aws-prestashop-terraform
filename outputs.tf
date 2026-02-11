output "website_url" {
  value = "http://${aws_instance.prestashop-server.public_ip}"
}

output "rds_endpoint" {
  value = aws_db_instance.prestashop_db.address
}

output "aws_instance_public_ip" {
  value = aws_instance.prestashop-server.public_ip
}