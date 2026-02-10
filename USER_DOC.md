# User Documentation

This documentation provides essential information for administrators and users to operate, manage, and verify the Inception infrastructure.

---

### Services Provided by the Stack
The infrastructure orchestrates three services that work together to host a secure web application:

* **NGINX**: Acts as the single entry point for the infrastructure. It is configured as a web server using TLS 1.3 to ensure all external communications are encrypted.
* **WordPress**: The content management system (CMS) that processes the website's logic. It runs via PHP-FPM to handle dynamic content.
* **MariaDB**: The relational database management system. It securely stores all site data, including user profiles, posts, and system configurations.

---

### Starting and Stopping the Project
Project management is simplified through a **Makefile** located at the root of the repository.

* **To start the project**: Run the command `make`. This command creates the necessary storage directories on the host, builds the container images, and launches the services in detached mode.
* **To stop the project**: Run the command `make down`. This stops the running containers but preserves the data stored in the volumes.
* **To fully reset the project**: Run the command `make fclean`. This stops the containers and permanently deletes the local data directories and volumes.

---

### Accessing the Website and Administration Panel
Once the services are active, the website can be reached through a browser using the domain name defined in the configuration.

* **Public Website**: Accessible at `https://ele-borg.42.fr`.
* **Administration Panel**: Accessible at `https://ele-borg.42.fr/wp-admin`. This panel allows administrators to manage the WordPress site, install themes, and configure plugins.

---

### Locating and Managing Credentials
Credentials and sensitive configuration are stored in two specific locations for security:

* **The .env file**: Found at the root of the project. This file contains non-sensitive environment variables such as the database name, the database username, and the site title.
* **The secrets folder**: Found at the root of the project. It contains plain text files for sensitive passwords:
    * `sql_password.txt`: Password for the MariaDB user account.
    * `sql_root_password.txt`: Password for the MariaDB root account.
    * `wp_password.txt`: Password for the WordPress administrator account.

To update a password, modify the corresponding file in the `secrets/` folder and restart the stack using `make re`.

---

### Checking Service Status
To ensure that all components are functioning correctly, you can perform the following checks:

* **Container Status**: Run `docker ps`. Verify that the containers for `nginx`, `wordpress`, and `mariadb` are listed with a status of "Up".
* **Live Logs**: Run `make logs`. This command streams the output of all containers, which is useful for verifying successful connections between WordPress and the database.
* **Network Response**: Run `curl -I -k https://ele-borg.42.fr`. A successful response (HTTP 200) indicates that the NGINX server is correctly receiving and processing requests.