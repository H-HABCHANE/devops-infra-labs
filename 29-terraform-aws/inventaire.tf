# Le pont Terraform → Ansible : Terraform connaît l'IP du serveur (output), il écrit lui-même
# l'inventaire Ansible. Plus de copier-coller d'adresse, et l'inventaire suit chaque recréation.
resource "local_file" "inventaire_ansible" {
  filename             = "${path.module}/../25-ansible/inventaire-aws.ini"
  file_permission      = "0644"
  directory_permission = "0755" # sinon 0777 par défaut (piège déjà vu au Jour 6)
  content              = <<-EOT
    # Fichier généré par Terraform (29-terraform-aws/inventaire.tf) : ne pas modifier à la main.
    [web]
    aws-1 ansible_host=${aws_instance.web.public_ip}

    [web:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=~/.ssh/cle-ansible
  EOT
}
