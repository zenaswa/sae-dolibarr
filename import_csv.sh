#!/bin/bash
set -e
cd $(dirname $0)

if [ ! -f "./data/clients.csv" ]; then
    echo "CSV file not found..."
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q "sae-dolibarr-mariadb-1"; then
    echo "Container Dolibarr is not running. Start the stack first with ./install.sh"
    exit 1
fi

docker cp ./data/clients.csv sae-dolibarr-mariadb-1:/tmp/import.csv

docker exec -i sae-dolibarr-mariadb-1 mariadb -u dolidbuser -pdolidbpass dolidb <<'EOF'
LOAD DATA INFILE '/tmp/import.csv'
INTO TABLE llx_societe
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(nom, address, zip, town, phone)
SET client = 1,
    fournisseur = 0,
    fk_pays = 1,
    fk_user_creat = 1,
    fk_stcomm = 0,
    entity = 1;
EOF

docker exec -i sae-dolibarr-mariadb-1 mariadb -u dolidbuser -pdolidbpass dolidb -e "SELECT COUNT(*) FROM llx_societe;"
