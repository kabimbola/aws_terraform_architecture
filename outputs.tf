output "url" {
  value = aws_route53_record.dns-record.fqdn
}

output "bastion-host-hostname" {
  value = aws_instance.bastion_host.public_dns
}

output "webserver1-private-IP" {
  value = aws_instance.webserver1.private_ip
}

output "webserver2-private-IP" {
  value = aws_instance.webserver2.private_ip
}

output "dbserver-hostname" {
  value = aws_db_instance.dbserver.address
}

