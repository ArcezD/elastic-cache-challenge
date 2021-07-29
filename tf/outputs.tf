output "postgres_instance" {
  description = "RDS instance root username"
  value       = {
    endpoint = "${aws_db_instance.default.address}:${aws_db_instance.default.port}"
    hostname = aws_db_instance.default.address
    port = aws_db_instance.default.port
    rds_username = aws_db_instance.default.username
  }
}

output "rds_password" {
  description = "RDS instance root password"
  value       = aws_db_instance.default.password
  sensitive   = true
}

output "aws_instance_public_endpoint" {
  value = "http://${aws_eip.web.public_dns}"
}