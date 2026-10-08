# SAE 5.1 - Installation d'un ERP/CRM avec Dolibarr
## 1. Présentation du projet
Ce projet consiste à mettre en place une solution ERP/CRM basée sur Dolibarr, hébergée localement à l'aide de Docker.
L'objectif est de proposer une installation automatisée de Dolibarr, l'importation de données clients depuis un fichier CSV ainsi qu'un système de sauvegarde permettant de restaurer les données en cas d'incident.
## 2. Objectifs
Les principaux objectifs du projet sont:
- Installer automatiquement Dolibar;
- Installer et utiliser une base de données MariaDB;
- Automatiser l'instalation avec le script install.sh;
- Importer les données clients à partir d'un fichier CSV;
- Automatiser l'importation avec le script import_csv.sh;
- Utiliser Docker et Docker Compose pour déployer la solution;
- Mettre en place une procédure de sauvegarde avec backup.sh;
- Permettre la restauration des données après un incident.

## 3. Technologies utilisées
- Debian
- Docker
- Docker Compose 
- Dolibarr
- MariaDB 
- Bash
- Git/GitHub
- CSV

## 4. Architecture
L'application est composée de deux conteneurs Docker:
- Dolibarr: conteneur web permettant d'accéder à l'ERP/CRM;
- MariaDB: conteneur contenant la base de données de Dolibarr.
Les données importantes sont conservées dans des volumes:
- '/home/dolibarr_mariadb': données MariaDB;
- '/home/dolibarr_documents': documents Dolibarr;
- '/home/dolibarr_custom': personnalisations Dolibarr.
L'application Dolibarr est accessible sur le port '8080'.

## 5. Prérequis

Avant de lancer le projet, il faut disposer de:

- Une machine Debian;
- Docker installé;
- Docker Compose disponible;
- Git installé;
- Les fichiers du projet.

## 6. Installation
Cloner le dépot:

'''bash
git clone https://github.com/zanaswa/sae-dolibarr.git

