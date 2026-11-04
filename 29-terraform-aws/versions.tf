terraform {
  required_version = ">= 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.69.0" # 6.69.x : version publiée depuis plus de 2 semaines
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5" # pour écrire l'inventaire Ansible
    }
  }
}

provider "aws" {
  region = var.region

  # Étiquettes ajoutées automatiquement à TOUTES les ressources créées par ce code :
  # on retrouve facilement ce qui appartient au labo (et ce qu'il faut détruire).
  default_tags {
    tags = {
      Projet   = "labo-terraform"
      GereePar = "terraform"
    }
  }
}
