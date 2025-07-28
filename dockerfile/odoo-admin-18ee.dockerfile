FROM odoo:18
USER root

# Switch to a different mirror
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://us.archive.ubuntu.com/ubuntu|' /etc/apt/sources.list

# Install pip (and any tools you want like nano)
RUN apt-get update && apt-get install -y \
    python3-pip \
    nano \
    && rm -rf /var/lib/apt/lists/*


# Install required Python packages with override
RUN pip install --break-system-packages \
    --ignore-installed \
    pydantic==2.10.6 \
    pydantic-core==2.27.2 \
    email_validator==2.2.0


