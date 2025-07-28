Here is a cleaned-up, professional, and complete version of your `README.md` file for this Odoo multi-instance Docker setup:

---

# 🐳 Odoo Multi-Instance Setup with Docker Compose

This setup helps you run **multiple isolated Odoo 18 Enterprise containers** for different purposes such as:

* Client-specific demos
* Testing new modules
* Isolated development environments

It includes:

* PostgreSQL as the database backend
* PgAdmin for DB GUI access
* Caddy as an HTTPS reverse proxy

Simply running `docker-compose up` will bring up the full environment.

---

## 🔧 Main Services (`docker-compose.yml`)

We have defined 4 core services:

1. **db**: PostgreSQL container
2. **pgadmin**: Web-based PostgreSQL management
3. **caddy**: Handles reverse proxy + automatic TLS
4. **odoo-admin-18ee**: Base Odoo Enterprise container, built from a custom Dockerfile

---

### 📌 Configuration Notes

#### 🗂 `db` Service

* PostgreSQL is configured with a sample user (`shamim`).
* You can change this username/password if needed.

#### 🧱 `odoo-admin-18ee` Service

* **Depends on `db`**, so it starts after the database.
* Built from `./dockerfile/odoo-admin-18ee.dockerfile`
* Uses Odoo config from `./conf/odoo.conf`
* Volume mounts:

  * `/mnt/odoo-18-ee`: Enterprise addons
  * `/mnt/extra-addons`: Custom addons
* Make sure the `db_user` and `db_password` in the Odoo config match those defined in the `db` service.
* Default command:

  ```bash
  odoo -d admin-db -i base,P1705_VendorBid,admin_reset
  ```
* Ensure that `db_filter = ^admin-db` is set inside `odoo.conf`.

---

## ➕ Adding a New Instance (e.g., for client "toyota")

You can easily add a new client instance without modifying the main `docker-compose.yml`.

---

### ✅ Step 1: Create a New Compose File

Create a file: `toyota-compose.yml`
Example content:

```yaml
services:
  odoo-toyota:
    image: odoo:18
    container_name: toyota-container
    depends_on:
      - db
    volumes:
      - /opt/odoo/server/odoo_18.0+e/odoo/addons:/mnt/odoo-18-ee
      - /opt/odoo/custom-addons/odoo-18ee-custom-addons:/mnt/extra-addons
      - ./conf/toyota.conf:/etc/odoo/odoo.conf
    command: >
      odoo -d toyota-db -i base,admin_reset,{module_name}
    networks:
      - odoo-net

networks:
  odoo-net:
    external: true
```

---

### ✅ Step 2: Create Odoo Config File

Create `conf/toyota.conf`:

```ini
[options]
admin_passwd = admin-12321
db_host = db
db_port = 5432
db_user = shamim
db_password = shamim
addons_path = /mnt/odoo-18-ee,/mnt/extra-addons
db_filter = ^toyota-db
```

> Make sure the database user (`db_user`) and password match the values used in your main `db` service.

---

### ✅ Step 3: Update Caddy Reverse Proxy

In `Caddyfile`, add:

```caddy
toyota.myodootest.space {
    reverse_proxy odoo-toyota:8069
    encode gzip
}
```

> This will route requests to `toyota.myodootest.space` to the correct container.

---

### ✅ Step 4: Run the Container

```bash
docker-compose -f toyota-compose.yml up -d
```

---

## 📌 Tips

* All services share the same Docker network `odoo-net`. Ensure it exists (`docker network create odoo-net`) or declare it as `external: true`.
* Each client/container should have:

  * Its own database
  * Its own config file
  * A unique subdomain entry in Caddy
* Avoid using the same port mappings if you're using Caddy for proxying. **You don't need to expose 8069 directly.**

---

## 🚀 Result

Each client will be accessible at their own subdomain, such as:

* `admin.myodootest.space`
* `toyota.myodootest.space`
* `bmw.myodootest.space`

And you can manage databases with PgAdmin on: `http://localhost:5050`

---

useful commands
1. Stop and Remove All Containers

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

2. (Optional but recommended) Remove Orphaned Volumes & Networks

If you know you're not using them:

docker volume prune -f
docker network prune -f

3. Remove Dangling Images

docker image prune -f

If you want to remove all unused images, even those not dangling:

docker image prune -a
