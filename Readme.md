# Inception

*This project has been created as part of the 42 curriculum by ele-borg.*

---

## Description

The Inception project introduces the fundamentals of system administration using Docker.
The objective is to create and deploy a small infrastructure composed of different services, each running in its own Docker container. This infrastructure will provide a Wordpress website accessible with HTTPS with automated setup and persistent data.

The setup consists of multiple services running in separate containers, managed by **Docker Compose**. This environment includes:
* A **MariaDB** database for data storage.
* A **WordPress** site running with **PHP-FPM**.
* An **NGINX** server acting as the only entry point.
* Dedicated **Docker Volumes** and a private **Docker Network**.

---

## Instructions

### Prerequisites
* **Docker** and **Docker Compose** installed.
* Sudo privileges to modify the `/etc/hosts` file.

### Installation
1.  Clone the repository.

2.  Create a `.env` file at the root with thefollowing data :
    LOGIN=ele-borg
    SQL_DATABASE=[db_name]
    SQL_USER=[user_name]
    SQL_HOST=mariadb
    WP_TITLE=[site_name]
    WP_USER=[admin_login]
    WP_EMAIL=[mail]
    DOMAIN_NAME=ele-borg.42.fr

3. Create a `secrets` folder at the root with 3 files (`sql_password.txt`, `sql_root_password.txt` and `wp_password.txt`) and write down in every file the password of your choice.

4.  Add the domain to your host file:
    enter the command 'sudo nano /etc/hosts' in your terminal and write down the line "127.0.0.1 ele-borg.42.fr" in the file

### Execution
The project is managed via a Makefile. Note that the up command automatically creates the necessary data directories in /home/erika/data/ to ensure volume persistence.
* make / make up: Creates local directories, builds images, and starts the infrastructure in detached mode.
* make down: Stops the containers but keeps the volumes and data intact.
* make clean: Stops containers and removes volumes and orphan networks.
* make fclean: Performs a full clean and deletes all data in /home/erika/data/.
* make re: Triggers a full reset (fclean) and restarts the infrastructure.
* make logs: Displays real-time logs for all containers.

### Accessing MariaDB
To access the MariaDB container and connect to the database:
1) Enter the running container's shell with the following command : docker exec -it mariadb sh
2) Connect to the database server with the command : 
mariadb -u root -p
You will be prompted for the root password (defined in your sql_root_password.txt secret)
3) Basic Commands After logging in:
- List databases: SHOW DATABASES;
- Switch to your project database: USE [db_name];

---

## Project Description

### Docker and Sources
The objective is to create and deploy a small infrastructure composed of different services, each running in its own Docker container.
Every service is built from a custom `Dockerfile` based on Debian. The configuration files for each service (Nginx `.conf`, entrypoint scripts, etc.) are included in the repository and injected into the containers during the build process to ensure a consistent environment across different host machines.
The project relies on:
* Dockerfiles to build custom images
* docker-compose.yml to define and connect services
* Environment variables for a dynamic configuration
* Volumes to ensure data persistence*

### Design Choices

* Each service runs in its own container to ensure isolation and modularity
* Docker Compose is used to manage multiple services easily
* Only port 443 is exposed to the host via NGINX. All other communication occurs within a private internal network.
* Docker volumes persist data independently of container lifecycles


### Technical Comparisons

#### Virtual Machines vs Docker

* **Virtual Machines** : A VM is a software-based emulation of physical hardware. It runs a complete Guest Operating System, including its own kernel, on top of a hypervisor. This requires dedicated hardware resources (CPU, RAM, and Disk) for each instance.

* **Docker**: Docker provides OS-level virtualization by creating isolated environments called containers. Unlike VMs, containers share the Host OS kernel and only package the application and its dependencies. 
This results in:
    * Lower resource consumption
    * Faster startup times
    * Better portability across environments

#### Secrets vs Environment Variables

* **Environment variables** are part of the container's configuration and are visible via inspection tools or process logs, making them suitable for non-sensitive data like database names
* **Secrets** are designed for sensitive information such as passwords. They are stored outside the container image and are mounted into a temporary filesystem (RAM) at runtime, preventing sensitive data from being persisted on disk

Secrets are strongly preferred in production environments.

#### Docker Network vs Host Network

*  **Docker Network** (Bridge) : It creates a private, virtual subnet on the host, with its own DNS. Containers connected to the same bridge network can communicate with each other using internal IP addresses or service names, while remaining isolated from external traffic unless a port is explicitly mapped.
*  **Host Network** : In this mode, the container shares the host’s networking namespace directly. The container does not get its own IP address allocated by Docker but uses the host's IP and listens directly on the host's ports.

#### Docker Volumes vs Bind Mounts
* **Docker Volumes** : Mechanism to preserve the data generated and used by Docker containers.
They are completely managed by Docker and stored in a specific part of the host filesystem (/var/lib/docker/volumes/ on Linux). They are independent of the host machine's directory structure, which make them highly portable. Volumes are isolated from the host's non-Docker processes, making them safer for sensitive data like databases.
Docker manages the lifecycle of Volumes (creation, deletion, and backups) through the Docker CLI.
* **Bind Mounts** : It is a direct link between a specific file of directory on the host machine and a path in the container.
The file or directory is referenced by its absolute path on the host machine, which make it less partable. Unlike volumes, the user or the host operating system manages these files, which can lead to security risks. Unlike volumes also, they are not managed by Docker and rely on the host machine's file system structure and permissions, requiring manual intervention to ensure the paths exist and are accessible.

---

### Resources

#### Documentation
* Docker Overview: https://docs.docker.com/get-started/overview/
* Docker Compose Specification: https://docs.docker.com/compose/compose-file/
* NGINX Documentation: https://nginx.org/en/docs/
* MariaDB Knowledge Base: https://mariadb.com/kb/en/
* WordPress CLI Handbook: https://make.wordpress.org/cli/handbook/

#### AI Usage
As part of the learning process for this project, AI was used as a pedagogical support tool for the following tasks:
* **Conceptual Learning**: Assisting in the overall understanding of the Inception architecture, specifically the interactions between services, the logic of container isolation, and the management of virtual networks.
* **Problem Solving**: Providing guidance on troubleshooting complex configuration issues and interpreting system logs to understand the behavior of the infrastructure.
* **Debugging & Logs**: Assisting in the interpretation of NGINX and PHP-FPM error logs to identify configuration issues.
* **Formatting**: Translating technical notes into English and structuring the final README.md to ensure it meets the project's requirements.
