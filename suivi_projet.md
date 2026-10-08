# Journal de bord

(remplacer les items en majuscule)

* Installation d’un ERP/CRM
* Wafa Zenasni
* Ikram Atqaoui
* 22/09/26


## Séance n° 1

* 22/09 - 13h
* Fait: Prise de connaissance du sujet
* À faire: Decouverte de Dolibarr avec installation simple sur une VM
* Difficultés rencontrées: 


## Séance n° 2

* 28/09 - 8h30
* Fait: Decouverte de Dolibarr avec installation simple sur une VM
* À faire: Importation des csv sur Dolibarr
* Difficultés rencontrées:


## Séance n° 3

* 28/09 - 14h30
* Fait: Début d'écriture du script d'importation des fichiers csv
* À faire: finir import_csv.sh
* Difficultés rencontrées: prise en main du language shell


## Séance n° 4

* 30/09 - 15h
* Fait: Creation du docker-compose.yml
* À faire: finir et tester
* Difficultés rencontrées: volumes paths incompatible windows, incomprehension des variable d'env CRON


## Séance n° 5

* 06/10 - 16h
* Fait: install.sh
* À faire: finir import_csv.sh, créer backup.sh
* Difficultés rencontrées: syntaxe shell


## Séance n° 6

* 07/10 - 19h30
* Fait: import.csv backup.csv
* À faire: test PRA complet, rédaction du README
* Difficultés rencontrées:
  * Commande `mysql` absente des images MariaDB récentes (remplacée par `mariadb`)
  * Privilège FILE manquant pour LOAD DATA (erreur "Access denied")


## Séance n° 7

* 08/10 - 17h30
* Fait:
  * Tests PRA valides
  * Corrections : ordre du GRANT FILE, chemins des volumes
  * Rédaction du README.md
