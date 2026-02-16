# Verification et verification des secrets et variables d'environnement
if [ -f /run/secrets/sql_root_password ]; then
    SQL_ROOT_PASSWORD=$(cat /run/secrets/sql_root_password)
else
    echo "Error: required secret: SQL_ROOT_PASSWORD"
    exit 1
fi

if [ -f /run/secrets/sql_password ]; then 
    SQL_PASSWORD=$(cat /run/secrets/sql_password)
else
    echo "Error: required secret: SQL_PASSWORD"
    exit 1
fi

if [ -z "${SQL_DATABASE}" ] || [ -z "${SQL_USER}" ]; then
    echo "Error: SQL_DATABASE or SQL_USER not set"
    exit 1
fi

# cree le dossier ou sera stocke le socket de communication interne (parfois il n'est pas installe par mariadb)
# utile pour la portabilite
mkdir -p /run/mysql
chown mysql:mysql /run/mysql
chmod 755 -R /run/mysql

# commande pour verifier l'existence du dossier /var/lib/mysql/$SQL_DATABASE (/var/lib/mysql/ est le chemin standard ou mariadb sotcker ses donnees)
# [] n'est pas une syntaxe mais une commande a part entiere (les espaces sont importants pour la syntaxe), un programme executable alias de la commande test
if [ -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Base de données déjà existante. Démarrage normal."
else
    echo "Première installation. Initialisation..."
    
    # démarrage de mysql en arriere plan
    # Sans le &, le script resterait bloqué sur le démarrage du serveur et n'exécuterait jamais la suite de la configuration SQL
    mysqld_safe --datadir=/var/lib/mysql &
    # service mariadb start
    
    # ATTENTE ACTIVE : On attend que le serveur soit réellement prêt
    # sleep 10
    echo "Attente du démarrage de MariaDB..."
    until mariadb-admin -u root ping >/dev/null 2>&1; do
        sleep 1
    done

    # Note: Au premier lancement, root n'a PAS de mot de passe, donc pas de -p
    # Création de la db, création de l'utilisateur erika avec tous les droits sur la db, rechargement imediats des droits
    mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mariadb -u root -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    # le systeme de permission de Mariadb Est sotcke sur le disque et est copie sur la RAM a chaque run
    # cette commande force mariadb a purger la RAM de cette table de persission et de la recharger integralement
    mariadb -u root -e "FLUSH PRIVILEGES;"

    # Sécurisation du compte Root (changement du mdp de root qui maintnt)
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    
    # Extinction propre du serveur temporaire
    # Ici, on doit utiliser le mot de passe qu'on vient de définir
    #mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown
    mariadb-admin -u root -p$SQL_ROOT_PASSWORD shutdown
    
    echo "Configuration terminée."
fi

# mkdir -p /run/mysqld
# chown -R mysql:mysql /run/mysqld

# 3. Lancement final du processus du conteneur
# exec <programme> est une commande qui remplace le processus actuel par <programme> 
# (sans exec le nouveau processus serait un processus enfant); le gardant en PID 1
echo "Démarrage définitif de MariaDB..."
exec mysqld --user=mysql




# NOTES sur les commandes
# - mariadb = client interface, outil de dialogue (CLI = client en langue de commande); 
#    Il sert uniquement à envoyer des requêtes écrites en langage SQL vers le serveur (le démon mysqld) et à afficher la réponse
#   la commande mariadb seule ouvre un 'shell' interatif ou taper les commandes
#   le drapeau -e permet d'envoyer la commande sans ouvrir l'interface interactive (Execute)
# - mariadb-admin = utilitaire d'administration systeme (langage = commandes systemes); 
#   Il ne sert pas à manipuler les données (il ne comprend pas le SELECT * FROM...), mais à manipuler le processus du serveur.
#   ex = -- ping : Est-ce que tu es allumé ?
#   -- shutdown : Éteins-toi proprement (ferme les fichiers, enregistre tout).
#   -- version : Quelle version utilises-tu ?
#   -- reload : Relis tes fichiers de configuration.
# - mysql = souvent lien symbolique vers mariadb (meme binaire)
# NB : mysqld (avec un d a la fin) est le serveur demon (langage = binaire)