# Récupération des secrets
SQL_ROOT_PASSWORD=$(cat /run/secrets/sql_root_password)
SQL_PASSWORD=$(cat /run/secrets/sql_password)

# démarrage du service
service mariadb start

echo "DEBUG: Root password is [$(cat /run/secrets/sql_root_password)]"
ls -l /run/secrets/

#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
#mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

# Vérification acces et configuration
if mariadb -u root -e "status" >/dev/null 2>&1; then
    # Ici on est connecté sans mot de passe, donc pas de -p
    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    
    # C'est CETTE ligne qui crée le mot de passe root
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mariadb -e "FLUSH PRIVILEGES;"
fi

#Extinction propre
mariadb-admin -u root -p$SQL_ROOT_PASSWORD shutdown

#lancement final du processus du conteneur
exec mysqld