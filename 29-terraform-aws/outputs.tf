output "compte" {
  description = "ARN de l'identité utilisée par Terraform"
  value       = data.aws_caller_identity.moi.arn
}

output "zones" {
  description = "Zones de disponibilité de la région"
  value       = data.aws_availability_zones.zones.names
}

output "ami_ubuntu" {
  description = "Image Ubuntu 24.04 la plus récente"
  value       = "${data.aws_ami.ubuntu.id} (${data.aws_ami.ubuntu.name})"
}

output "ip_publique" {
  description = "Adresse publique du serveur"
  value       = aws_instance.web.public_ip
}

output "ssh" {
  description = "Commande de connexion SSH"
  value       = "ssh -i ~/.ssh/cle-ansible ubuntu@${aws_instance.web.public_ip}"
}
