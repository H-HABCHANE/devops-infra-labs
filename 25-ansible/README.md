# Ansible : configurer des serveurs par SSH

Ansible configure l'**intérieur** des serveurs (paquets, fichiers, services) par SSH, sans agent installé.
Pour s'entraîner sans cloud, les « serveurs » sont des conteneurs Ubuntu qui se comportent comme des instances
EC2 : SSH, utilisateur `ubuntu`, `sudo`, Python.

## Contenu

| Fichier | Rôle |
|---|---|
| `labo/Dockerfile` | faux serveur Ubuntu 24.04 : sshd, python3, sudo sans mot de passe, clé publique injectée au build |
| `inventaire.ini` | groupe `web` : `serveur-1` (port 2222) et `serveur-2` (port 2223), utilisateur et clé dédiée |
| `ansible.cfg` | inventaire par défaut ; empreintes SSH en `accept-new` (accepte un nouveau serveur, refuse une empreinte changée) |
| `site.yml` | le playbook : nginx installé, configuré et démarré |
| `templates/` | modèles Jinja2 de la configuration nginx et de la page d'accueil |

Le même playbook configure aussi une **vraie instance EC2** créée par Terraform : voir
[`29-terraform-aws`](../29-terraform-aws/), qui génère `inventaire-aws.ini` (fichier non versionné).

## Le playbook

1. installer nginx (`apt`, cache valide 1 h) ;
2. déposer la configuration du site depuis un modèle → **notifie** le handler « Recharger nginx » ;
3. déposer une page d'accueil personnalisée par serveur (`{{ inventory_hostname }}`) ;
4. déposer un fichier de configuration sensible en `0600` (propriétaire root), avec `no_log: true` pour que la valeur
   n'apparaisse jamais dans la sortie, `--diff` ou les logs ;
5. démarrer nginx et l'activer au démarrage.

## Lancer

```bash
ssh-keygen -t ed25519 -f ~/.ssh/cle-ansible -N ""
docker build -t serveur-ssh --build-arg CLE_PUBLIQUE="$(cat ~/.ssh/cle-ansible.pub)" labo/
docker run -d --name serveur-1 -p 127.0.0.1:2222:22 serveur-ssh
docker run -d --name serveur-2 -p 127.0.0.1:2223:22 serveur-ssh
ansible web -m ping
ansible-playbook site.yml --syntax-check && ansible-playbook site.yml
```

## Ce que ce lab démontre

- **Idempotence** : 1er passage `changed=6`, 2e passage `changed=0` (rien à faire, rien n'est touché).
- **Correction du drift** : un fichier modifié à la main sur un seul serveur est réparé au passage suivant, seulement
  sur ce serveur, et le handler ne recharge nginx que là où la configuration a changé.
- Terraform **crée** l'infrastructure, Ansible la **configure** : les deux seront combinés dans le projet final
  (l'adresse de l'instance créée par Terraform alimente l'inventaire).
