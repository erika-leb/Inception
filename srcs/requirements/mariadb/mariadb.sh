# Récupération des secrets
SQL_ROOT_PASSWORD=$(cat /run/secrets/sql_root_password)
SQL_PASSWORD=$(cat /run/secrets/sql_password)

# commande pour verifier l'existence du dossier /var/lib/mysql/$SQL_DATABASE (/var/lib/mysql/ est le chemin standard ou mariadb sotcker ses donnees)
# [] n'est pas une syntaxe mais une commande a part entiere (les espaces sont importants pour la syntaxe), un programme executable alias de la commande test
if [ -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Base de données déjà existante. Démarrage normal."
else
    echo "Première installation. Initialisation..."
    
    # démarrage du service
    service mariadb start
    
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
    mariadb -u root -e "FLUSH PRIVILEGES;"

    # Sécurisation du compte Root (changement du mdp de root qui maintnt)
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    
    # Extinction propre du serveur temporaire
    # Ici, on doit utiliser le mot de passe qu'on vient de définir
    #mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown
    mariadb-admin -u root -p$SQL_ROOT_PASSWORD shutdown
    
    echo "Configuration terminée."
fi

# 3. Lancement final du processus du conteneur
# exec <programme> est une commande qui remplace le processus actuel par <programme> 
# (sans exec le nouveau processus serait un processus enfant); le gardant en PID 1
echo "Démarrage définitif de MariaDB..."
exec mysqld




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