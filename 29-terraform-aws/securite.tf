# Le videur du serveur : SSH seulement depuis mon IP, HTTP pour tout le monde.
resource "aws_security_group" "web" {
  name        = "web-labo-tf"
  description = "SSH depuis mon IP, HTTP public"
  vpc_id      = aws_vpc.labo.id
  tags        = { Name = "web-labo-tf" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH depuis mon IP seulement"
  cidr_ipv4         = var.mon_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP public"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "tout" {
  security_group_id = aws_security_group.web.id
  description       = "Sortie : tout (mises a jour apt, etc.)" # AWS refuse les accents dans les descriptions de règles
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Le cadenas SSH : on envoie seulement la clé PUBLIQUE (la privée ne quitte jamais le PC).
resource "aws_key_pair" "labo" {
  key_name   = "cle-ansible-tf"
  public_key = file(pathexpand("~/.ssh/cle-ansible.pub"))
}
