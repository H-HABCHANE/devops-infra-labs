variable "region" {
  description = "Région AWS (Paris)"
  type        = string
  default     = "eu-west-3"
}

variable "mon_ip" {
  description = "Mon adresse IP publique en /32 : seule autorisée en SSH (ex. 46.193.67.196/32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.mon_ip, 0)) && endswith(var.mon_ip, "/32")
    error_message = "Donne une seule adresse au format CIDR /32 (jamais 0.0.0.0/0 pour SSH)."
  }
}

variable "type_instance" {
  description = "Taille du serveur (t3.micro : éligible au plan gratuit)"
  type        = string
  default     = "t3.micro"
}
