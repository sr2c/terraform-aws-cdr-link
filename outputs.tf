
output "es_hostname" {
  value = module.elasticsearch[0].domain_hostname
}

output "instance_id" {
  value = aws_instance.default[0].id
}

output "rds_metamigo_password" {
  value     = random_password.metamigo[0].result
  sensitive = true
}

output "rds_metamigo_authenticator_password" {
  value     = random_password.metamigo[0].result
  sensitive = true
}

output "rds_hostname" {
  value = split(":", module.rds[0].instance_endpoint)[0]
}

output "rds_port" {
  value = split(":", module.rds[0].instance_endpoint)[1]
}

output "rds_superuser_user" {
  value = "cdrlink"
}

output "rds_superuser_password" {
  value     = random_password.rds_superuser[0].result
  sensitive = true
}

output "rds_zammad_password" {
  value     = random_password.zammad[0].result
  sensitive = true
}

output "zammad_monitoring_token" {
  value = random_password.zammad[0].result
}
