# Récupération des secrets
SQL_ROOT_PASSWORD=$(cat /run/secrets/sql_root_password)
SQL_PASSWORD=$(cat /run/secrets/sql_password)

#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
#mariadb -h localhost -u root -p$SQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
#mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

if [ -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Base de données déjà existante. Démarrage normal."
else
    echo "Première installation. Initialisation..."
    
    # démarrage du service
    service mariadb start
    
    # ATTENTE ACTIVE : On attend que le serveur soit réellement prêt
    # C'est souvent là que ça plante : le service start rend la main trop vite
    sleep 10

    # Note: Au premier lancement, root n'a PAS de mot de passe, donc pas de -p
    # Création de la db, création de l'utilisateur erika avec tous les droits sur la db, rechargement imediats des droits
    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mariadb -u root -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mariadb -u root -e "FLUSH PRIVILEGES;"

    # Sécurisation du compte Root (changement du mdp de root qui maintnt)
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    
    # Extinction propre du serveur temporaire
    # Ici, on doit utiliser le mot de passe qu'on vient de définir
    mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown
    
    echo "Configuration terminée."
fi

## Vérification acces et configuration
#if mariadb -u root -e "status" >/dev/null 2>&1; then
#    # Ici on est connecté sans mot de passe, donc pas de -p
#    mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
#    mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
#    mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
#    
#    # C'est CETTE ligne qui crée le mot de passe root
#    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
#    mariadb -e "FLUSH PRIVILEGES;"
#fi

#Extinction propre
#mariadb-admin -u root -p$SQL_ROOT_PASSWORD shutdown

# 3. Lancement final
# exec remplace le processus shell actuel par mysqld, le gardant en PID 1
echo "Démarrage définitif de MariaDB..."
exec mysqld_safe

#sans exec mysqld aurait ete lance comme enfant

#lancement final du processus du conteneur
#exec mysqld