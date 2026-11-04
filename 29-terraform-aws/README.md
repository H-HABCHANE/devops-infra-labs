# Terraform sur AWS : un serveur web complet, puis configuré par Ansible

Le réseau construit à la main dans la console AWS (VPC, sous-réseau public, passerelle Internet, groupe de sécurité,
EC2) est ici décrit en code. Terraform crée l'infrastructure et **écrit lui-même l'inventaire Ansible** ; le playbook de
[`25-ansible`](../25-ansible/) configure ensuite le serveur.

## Architecture

```
VPC 10.0.0.0/16 (eu-west-3)
└── subnet public 10.0.1.0/24 (eu-west-3a) ── table de routage : 0.0.0.0/0 → passerelle Internet
    └── EC2 t3.micro Ubuntu 24.04 ── groupe de sécurité : SSH depuis une seule IP (/32), HTTP public
                                     disque gp3 chiffré, IMDSv2 obligatoire
Terraform ──IP publique──► 25-ansible/inventaire-aws.ini ──► ansible-playbook site.yml ──► nginx
```

| Fichier | Rôle |
|---|---|
| `versions.tf` | providers `hashicorp/aws ~> 6.69.0` et `hashicorp/local` ; `default_tags` sur toutes les ressources |
| `variables.tf` | région, type d'instance, `mon_ip` **validée** (une seule adresse /32 : SSH jamais ouvert au monde) |
| `main.tf` | lectures seules : identité, zones de disponibilité, dernière image Ubuntu 24.04 officielle (propriétaire Canonical) |
| `reseau.tf` | VPC, sous-réseau public, passerelle Internet, routes |
| `securite.tf` | groupe de sécurité (une ressource par règle, avec description), paire de clés (clé publique seulement) |
| `serveur.tf` | instance EC2 ; `ignore_changes = [ami]` pour ne pas la remplacer à chaque nouvelle image |
| `inventaire.tf` | génère l'inventaire Ansible à partir de l'IP publique (permissions explicites 0644 / 0755) |
| `.terraform.lock.hcl` | versions et empreintes exactes des providers |

## Lancer

Identifiants **temporaires** (aucune clé d'accès permanente) :

```bash
aws login --remote --region eu-west-3      # session de la console d'un utilisateur IAM (jamais root)
aws sts get-caller-identity

terraform init
terraform plan -var "mon_ip=$(curl -s https://checkip.amazonaws.com)/32" -out=labo.tfplan
terraform apply labo.tfplan                # crée le serveur et écrit ../25-ansible/inventaire-aws.ini

cd ../25-ansible
ansible-playbook -i inventaire-aws.ini site.yml --check --diff   # relire avant d'agir
ansible-playbook -i inventaire-aws.ini site.yml                  # puis changed=0 au 2e passage
curl http://<ip_publique>

cd ../29-terraform-aws
terraform plan -destroy -var "mon_ip=..." -out=destroy.tfplan && terraform apply destroy.tfplan
```

## Ce que ce lab démontre

- **Relire le plan, y compris ce qu'on n'a pas écrit** : la revue a repéré une permission de dossier `0777` par défaut
  (fixée à `0755`) et vérifié que SSH n'était ouvert qu'à une adresse /32.
- **Échec partiel sans rollback** : une description de règle refusée par AWS (caractère accentué) a laissé 10 ressources
  sur 11 créées ; après correction, le plan suivant ne proposait que la ressource manquante, grâce au state.
- **Terraform crée, Ansible configure** : inventaire généré automatiquement, même playbook que sur les serveurs simulés
  en conteneurs, idempotence vérifiée sur la vraie instance (`changed=0` au 2e passage).
- **Destruction vérifiée** : ordre inverse du graphe (le VPC en dernier), puis contrôle par l'AWS CLI qu'aucune
  instance, aucun volume ni aucune IP ne restait, grâce aux étiquettes communes.
