
# SAE 5.1 - Installation d'un ERP/CRM avec Dolibarr

## 1. Présentation du projet

Ce projet consiste à mettre en place une solution ERP/CRM basée sur Dolibarr,
hébergée localement à l'aide de Docker. L'objectif est de proposer une
installation automatisée de Dolibarr, l'importation de données clients depuis un
fichier CSV, ainsi qu'un système de sauvegarde permettant de restaurer les
données en cas d'incident (PRA).

Il s'agit d'un POC (Proof of Concept) : on se limite à la gestion des "Tiers"
(clients / fournisseurs). Ce n'est pas une mise en production.

## 2. Objectifs

- Installer automatiquement Dolibarr et la base de données MariaDB
- Automatiser l'installation via `install.sh`
- Importer les données clients depuis un fichier CSV via `import_csv.sh`
- Mettre en place une sauvegarde via `backup.sh`
- Permettre la restauration complète après un incident (PRA)
- Déployer l'ensemble avec Docker et Docker Compose

## 3. Technologies utilisées

- Debian 12 (Bookworm)
- Docker / Docker Compose
- Dolibarr (image officielle `dolibarr/dolibarr:latest`)
- MariaDB (image officielle `mariadb:latest`)
- Bash
- Git / GitHub

## 4. Architecture

L'application est composée de deux conteneurs Docker :

- **web** : Dolibarr exposé sur le port `8080`
- **mariadb** : base de données utilisée par Dolibarr

Les données persistantes sont conservées dans trois répertoires de l'hôte,
montés dans les conteneurs (bind mounts) :

- `/home/dolibarr_mariadb` → `/var/lib/mysql` dans le conteneur MariaDB
- `/home/dolibarr_documents` → `/var/www/documents` dans le conteneur Dolibarr
- `/home/dolibarr_custom` → `/var/www/html/custom` dans le conteneur Dolibarr

Ces répertoires survivent à un `docker compose down` ou à un redémarrage des
conteneurs. Seule la suppression manuelle des répertoires hôte (ou de la machine)
provoque une perte de données — c'est le scénario que le PRA couvre.

## 5. Prérequis

Sur la machine cible :

- Debian (ou toute distribution Linux avec systemd)
- Docker Engine et le plugin Docker Compose
- Git
- L'utilisateur courant doit être membre du groupe `docker` :

```bash
sudo usermod -aG docker $USER
```

Puis se déconnecter et se reconnecter (ou `newgrp docker`) pour que le changement
prenne effet.


## 6. Structure du dépôt

```
sae-dolibarr/
├── docker-compose.yml     # Définition des deux services
├── install.sh             # Installation + restauration automatique (PRA)
├── import_csv.sh          # Import des données clients depuis un CSV
├── backup.sh              # Sauvegarde base + fichiers
├── data/
│   └── clients.csv        # Données à importer
├── backups/               # Généré par backup.sh (non versionné)
└── README.md
```

## 7. Installation

```bash
git clone https://github.com/zenaswa/sae-dolibarr.git
cd sae-dolibarr
./install.sh
```

Le script `install.sh` effectue les étapes suivantes :

1. Vérifie que Docker est installé et que le démon est démarré
2. Démarre les conteneurs MariaDB et Dolibarr via `docker compose up -d`
3. Attend que l'interface web réponde (boucle sur `curl`)
4. Accorde le privilège `FILE` à l'utilisateur `dolidbuser` (nécessaire pour
   `LOAD DATA` utilisé par `import_csv.sh`)
5. Si un dossier `./backups/` contenant un dump SQL existe, lance la restauration
   (voir section 9) puis redémarre le conteneur web

Une fois l'installation terminée, l'application est accessible sur :

- URL : http://localhost:8080
- Identifiant : `admin`
- Mot de passe : `admin`

Il est recommandé de changer le mot de passe immédiatement après la première
connexion.

## 8. Import des données CSV

Format attendu (séparateur virgule, encodage UTF-8, fins de ligne LF) :

```csv
nom,address,zip,town,phone
Boulangerie Lefebvre,12 Rue du Vieux Marché,76000,Rouen,0235714582
...
```

Placez le fichier dans `./data/clients.csv`, puis lancez :

```bash
./import_csv.sh
```

Le script copie le CSV dans le conteneur MariaDB et exécute une commande
`LOAD DATA INFILE` qui insère les lignes directement dans la table
`llx_societe`, en court-circuitant l'interface web de Dolibarr.

Les champs `client`, `fournisseur`, `fk_pays`, `fk_user_creat`, `fk_stcomm` et
`entity` sont fixés par le script pour garantir que les tiers importés soient
visibles dans l'interface (certains champs obligatoires ne sont pas dans le CSV).

## 9. Sauvegarde et restauration (PRA)

### Sauvegarde

```bash
./backup.sh
```

Génère deux fichiers horodatés dans `./backups/` :

- `db-<timestamp>.sql` : dump complet de la base `dolidb` (commande `mariadb-dump`)
- `volumes-<timestamp>.tar.gz` : archive des répertoires `/home/dolibarr_documents`
  et `/home/dolibarr_custom`

Les deux sont nécessaires : la base contient les données structurées (tiers,
utilisateurs, paramètres), tandis que les répertoires contiennent les fichiers
générés par Dolibarr (PDF de factures, logos uploadés, `install.lock`, modules
externes). La base ne stocke que des références vers ces fichiers ; sans eux,
certaines fonctionnalités échouent silencieusement.

Le dossier `./backups/` est volontairement situé hors des bind mounts, afin de
survivre à une suppression accidentelle des répertoires de persistance. En
production, il faudrait également le copier sur un support externe.

### Restauration

La restauration est **intégrée à `install.sh`**. Il suffit que le dossier
`./backups/` contienne un dump pour que le script bascule automatiquement en
mode restauration :

1. Détection de `./backups/db-*.sql`
2. Export de `DOLI_INSTALL_AUTO=0` avant `docker compose up`, pour que Dolibarr
   n'initialise pas de tables vides qui bloqueraient le dump (erreurs de type
   "table already exists")
3. Démarrage des conteneurs
4. Restauration de la base via `mariadb < db-*.sql`
5. Extraction du tar dans `/home`
6. Redémarrage du conteneur web pour qu'il recharge la configuration

Scénario complet de test PRA :

```bash
./backup.sh
docker compose down -v
sudo rm -rf /home/dolibarr_mariadb /home/dolibarr_documents /home/dolibarr_custom
./install.sh
```

Après l'exécution, les données (tiers, utilisateurs, permissions) doivent être
intégralement revenues.

## 10. Décisions techniques

- **Bind mounts plutôt que volumes nommés** : les données sont directement
  visibles et sauvegardables depuis l'hôte, sans avoir à passer par des
  commandes Docker pour les extraire.
- **`DOLI_INSTALL_AUTO=0` en mode restauration** : sans cela, Dolibarr
  auto-installe les 410 tables de son schéma au premier démarrage, et le dump
  pourrait echouer. Le passage à 0 laisse la base vide
  pour que le dump puisse la reconstruire proprement.
- **`GRANT FILE` pour `dolidbuser`** : `LOAD DATA INFILE` nécessite le privilège
  global `FILE`, que le compte `dolidbuser` n'a pas par défaut. Le privilège est
  accordé dans `install.sh` via une connexion root ponctuelle.

## 12. Sources


- Page Dolibarr du dockerhub: https://hub.docker.com/r/dolibarr/dolibarr
- Deepseek
