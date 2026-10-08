#!/bin/bash
set -e
cd $(dirname $0)

mkdir -p ./backups

docker exec sae-dolibarr-mariadb-1 mariadb-dump -u root -proot dolidb > ./backups/db-$(date +%Y%m%d-%H%M%S).sql
tar czf ./backups/volumes-$(date +%F-%H%M%S).tar.gz -C /home dolibarr_documents dolibarr_custom
echo "Backup done."
