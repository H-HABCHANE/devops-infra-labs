resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.type_instance
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.labo.key_name

  # IMDSv2 obligatoire : protège les identifiants du serveur contre certaines attaques (SSRF)
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = "web-labo-tf" }

  # La nouvelle image Ubuntu publiée chaque semaine ne doit pas remplacer le serveur à chaque plan
  lifecycle {
    ignore_changes = [ami]
  }
}
