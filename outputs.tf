
output "es_hostname" {
  value = module.elasticsearch[0].domain_hostname
}

output "rds_hostname" {
  value = module.rds[0].hostname
}

output "rds_superuser_user" {
  value = "cdrlink"
}

output "rds_superuser_password" {
  value = random_password.rds_superuser[0].result
}
