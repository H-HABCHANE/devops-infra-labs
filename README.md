# devops-infra-labs

Labs pratiques réalisés pendant un programme intensif DevOps / Cloud (préparation d'un stage) : intégration continue,
Linux et Bash, Infrastructure as Code, gestion de configuration et supervision. Chaque dossier contient du code
qui tourne, un `README.md` qui explique l'objectif, ce qui a été fait, comment le relancer et ce que cela démontre.

Fil conducteur : un **restaurant** (prix TTC des plats, menu, site vitrine, carte servie par une API).

## Parcours

| Jour | Thème | Dossier | En bref |
|---|---|---|---|
| 1-2 | Kubernetes (Minikube) | dépôt séparé | Pods, Deployments, Services, ConfigMaps, probes, mises à jour progressives |
| 3 | CI/CD avec GitHub Actions | [`02-appli-python`](02-appli-python/), [`.github/workflows`](.github/workflows/) | Tests et lint à chaque PR, image Docker publiée sur Docker Hub, branche `main` protégée |
| 4 | Linux, réseau, Bash, Git | [`12-bash`](12-bash/) | Script de diagnostic DNS → port → HTTP avec codes de sortie, rebase et résolution de conflit |
| 5 | AWS (console) | — | IAM (moindre privilège, rôles), VPC sur mesure, EC2 + SSH, déploiement Docker, S3 privé, CloudWatch, nettoyage complet |
| 6 | Terraform | [`22-terraform-bases`](22-terraform-bases/), [`23-terraform-docker`](23-terraform-docker/) | Cycle init/plan/apply, state, drift, modules, refactoring avec `moved`, destroy |
| 6 bis | Ansible | [`25-ansible`](25-ansible/) | Inventaire, playbook idempotent, modèles Jinja2, handlers, sur des serveurs simulés en conteneurs puis sur une EC2 |
| 6 ter | Terraform sur AWS | [`29-terraform-aws`](29-terraform-aws/) | VPC, groupe de sécurité et EC2 en code, identifiants temporaires, inventaire Ansible généré, destroy vérifié |
| 7 | Supervision | [`26-prometheus`](26-prometheus/) | Prometheus, Grafana, alertes, Alertmanager, sonde boîte noire, incident simulé et post-mortem |
| 8-9 | Projet final | [restaurant-api](https://github.com/H-HABCHANE/restaurant-api) | API FastAPI instrumentée, CI, Kubernetes, IaC, supervision |

## Pratiques suivies dans ce dépôt

- Tout changement passe par une **branche et une pull request** ; `main` est protégée par un check obligatoire (`tests`).
- Versions **épinglées** (images Docker, dépendances Python, providers Terraform avec fichier de verrouillage).
- Aucun secret dans le code : identifiants Docker Hub dans les secrets GitHub Actions, ports publiés sur `127.0.0.1`.
- Les configurations sont **vérifiées avant d'être appliquées** (`ruff`, `pytest`, `terraform validate` / `plan`,
  `ansible-playbook --syntax-check`, `promtool`, `amtool`).

## Outils

GitHub Actions · Docker / Docker Compose · Bash · AWS · Terraform 1.17 · Ansible 2.21 · Prometheus 3 · Grafana 13 ·
Alertmanager · Python 3.14 (pytest, ruff)
