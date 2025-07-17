# odoo-on-docker

This project sets up an Odoo 18 Enterprise environment using Docker.

## Generate Self-Signed SSL Certificates

Before starting the containers, generate self-signed SSL certificates.  
Run the following commands **from your project root directory**:

```bash
# Create the certs directory
mkdir -p certs

# Generate self-signed certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/selfsigned.key \
  -out certs/selfsigned.crt \
  -subj "/CN=localhost"
```
