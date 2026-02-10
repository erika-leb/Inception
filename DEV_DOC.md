# Developer Documentation

This document provides technical instructions for developers to set up, build, and manage the Inception infrastructure.

---

### Environment Setup

To set up the development environment from scratch, follow these steps:

**1. Prerequisites**
* Operating System: Linux (preferred) or a VM running Linux.
* Tools: **Docker** (Engine and CLI) and **Docker Compose**.
* Privileges: Sudo access to modify system files and manage Docker.

**2. Configuration Files**
Create a `.env` file at the root with thefollowing data :
SQL_DATABASE=[db_name]
SQL_USER=[user_name]
SQL_HOST=mariadb
WP_TITLE=[site_name]
WP_USER=[admin_login]
WP_EMAIL=[mail]
DOMAIN_NAME=ele-borg.42.fr

**3. Secrets Setup**
Sensitive data is managed via the `secrets/` directory. Create this folder at the root and add the following files:
* `sql_password.txt`: The database user password.
* `sql_root_password.txt`: The database root password.
* `wp_password.txt`: The WordPress administrator password.

**4. Data persistence and volumes**
Storage Locations Volumes are bind-mounted to the host. Important: You must adapt these paths in **docker-compose.yml** and **Makefile** to match your current system user (e.g., replace [user] with ele-borg or erika).
- MariaDB data → /home/[user]/data/mariadb
- WordPress data → /home/[user]/data/wordpress

---

### Building and Launching the Project

The project is orchestrated using **Docker Compose** and managed via a **Makefile** to ensure consistency.

### Execution
The project is managed via a Makefile. Note that the up command automatically creates the necessary data directories in /home/erika/data/ to ensure volume persistence.

**Makefile commands** 
* **make / make up***: Creates local directories, builds images, and starts the infrastructure in detached mode.
* **make down**: Stops the containers but keeps the volumes and data intact.
* **make clean**: Stops containers and removes volumes and orphan networks.
* **make fclean**: Performs a full clean and deletes all data in /home/erika/data/.
* **make re**: Triggers a full reset (fclean) and restarts the infrastructure.
* **make logs**: Displays real-time logs for all containers.

**docker management commands**
* **docker ps**: Lists running containers 
* **docker compose -f srcs/docker-compose.yml logs [container_name]**: view logs per service
* **docker exec -t [container_name] bash**: execute a shell inside a container
* **docker volume ls**: lists volumes

