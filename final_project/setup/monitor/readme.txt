Run these command in the EC2:
sudo apt update
sudo apt upgrade  -y

Steps to use the script
create the script as install_prometheus.sh:

Copy code:
nano install_prometheus.sh

copy the following script:
#--------------------------------------code start

#!/bin/bash

# Variables
PROMETHEUS_VERSION="2.53.1"
PROMETHEUS_USER="prometheus"
PROMETHEUS_GROUP="prometheus"
PROMETHEUS_DIR="/usr/local/bin/prometheus-${PROMETHEUS_VERSION}"
CONFIG_FILE="${PROMETHEUS_DIR}/prometheus.yml"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Extract the tarball
tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Move the extracted files
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 ${PROMETHEUS_DIR}

# Create symbolic links
sudo ln -s ${PROMETHEUS_DIR}/prometheus /usr/local/bin/prometheus
sudo ln -s ${PROMETHEUS_DIR}/promtool /usr/local/bin/promtool

# Create Prometheus configuration file
sudo tee ${CONFIG_FILE} > /dev/null <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOL

# Create a Prometheus user and group
sudo useradd --no-create-home --shell /bin/false ${PROMETHEUS_USER}
sudo mkdir -p ${PROMETHEUS_DIR}/data
sudo chown -R ${PROMETHEUS_USER}:${PROMETHEUS_GROUP} ${PROMETHEUS_DIR}

# Create Prometheus service file
sudo tee ${SERVICE_FILE} > /dev/null <<EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=${PROMETHEUS_USER}
Group=${PROMETHEUS_GROUP}
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=${CONFIG_FILE} --storage.tsdb.path=${PROMETHEUS_DIR}/data

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Clean up
rm prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

echo "Prometheus installation and setup completed."

#------------------------------------end of the code 
save and exit

copy this commad:
chmod +x install_prometheus.sh

Run the script:
sudo ./install_prometheus.sh

After running the script, Prometheus will be installed and running in the background as a systemd service. You can check its status with:
 Run this commad to see the status of the 
sudo systemctl status prometheus

You can also manage the Prometheus service using standard systemd commands, such as:

Stop Prometheus:
sudo systemctl stop prometheus

Start Prometheus:
sudo systemctl start prometheus

Restart Prometheus:
sudo systemctl restart prometheus

Enable Prometheus to start on boot:
sudo systemctl enable prometheus

Disable Prometheus from starting on boot:
sudo systemctl disable prometheus



open browser:
the prot: 9090

52.201.178.63:9090




install graphan:
https://mjoulani1975.grafana.net/


run the following command:
sudo nano grafana.sh

past in the file grafana.sh
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_11.1.0_amd64.deb
sudo dpkg -i grafana-enterprise_11.1.0_amd64.deb

exit save

sudo chmod +x grafana.sh
./grafana.sh

start grafana
 sudo /bin/systemctl daemon-reload
 sudo /bin/systemctl enable grafana-server
### You can start grafana-server by executing
sudo /bin/systemctl start grafana-server
sudo systemctl status grafana-server

grafana run in port : 3000
52.201.178.63:3000

istall blackbox:
go to the url : https://prometheus.io/download/

search for blackbox_exporter
create file install_blackbox_exporter.sh
sudo nano install_blackbox_exporter

copy past the following script:

#!/bin/bash

# Variables
BLACKBOX_VERSION="0.25.0"
BLACKBOX_USER="blackbox_exporter"
BLACKBOX_GROUP="blackbox_exporter"
BLACKBOX_DIR="/usr/local/bin/blackbox_exporter-${BLACKBOX_VERSION}"
CONFIG_FILE="${BLACKBOX_DIR}/blackbox.yml"
SERVICE_FILE="/etc/systemd/system/blackbox_exporter.service"

# Download Blackbox Exporter
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz

# Extract the tarball
tar -xvf blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz

# Move the extracted files
sudo mv blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64 ${BLACKBOX_DIR}

# Create symbolic link
sudo ln -s ${BLACKBOX_DIR}/blackbox_exporter /usr/local/bin/blackbox_exporter

# Create Blackbox Exporter configuration file
sudo tee ${CONFIG_FILE} > /dev/null <<EOL
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      valid_status_codes: []
      method: GET
      no_follow_redirects: false
      fail_if_ssl: false
      fail_if_not_ssl: false
EOL

# Create a Blackbox Exporter user and group
sudo useradd --no-create-home --shell /bin/false ${BLACKBOX_USER}
sudo chown -R ${BLACKBOX_USER}:${BLACKBOX_GROUP} ${BLACKBOX_DIR}

# Create Blackbox Exporter service file
sudo tee ${SERVICE_FILE} > /dev/null <<EOL
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${BLACKBOX_USER}
Group=${BLACKBOX_GROUP}
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file=${CONFIG_FILE}

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start Blackbox Exporter
sudo systemctl daemon-reload
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter

# Clean up
rm blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz

echo "Blackbox Exporter installation and setup completed."

save and exit

sudo chmod +x install_blackbox_exporter.sh
./install_blackbox_exporter.sh

After running the script, the Blackbox Exporter will be installed and configured to run as a systemd service. 
You can check its status with:
sudo systemctl status blackbox_exporter

You can also manage the Blackbox Exporter service using standard systemd commands, such as:

Stop Blackbox Exporter:
sudo systemctl stop blackbox_exporter

Start Blackbox Exporter:
sudo systemctl start blackbox_exporter

Restart Blackbox Exporter:
sudo systemctl restart blackbox_exporter

Enable Blackbox Exporter to start on boot:
sudo systemctl enable blackbox_exporter

Disable Blackbox Exporter from starting on boot:
sudo systemctl disable blackbox_exporter




copy from the Readme.md :
https://github.com/prometheus/blackbox_exporter/blob/master/README.md
under Prometheus Configuration:
copy the code under Example config


port:9115
check:
52.201.178.63:9115

this script install_prometheus and install_blackbox_exporter and grafana and autostarted:





#!/bin/bash

# Variables
PROMETHEUS_VERSION="2.53.1"
BLACKBOX_VERSION="0.25.0"
GRAFANA_VERSION="10.0.2"  # Update this to the latest version if needed

PROMETHEUS_USER="prometheus"
PROMETHEUS_GROUP="prometheus"
PROMETHEUS_DIR="/usr/local/bin/prometheus-${PROMETHEUS_VERSION}"
PROMETHEUS_CONFIG_FILE="${PROMETHEUS_DIR}/prometheus.yml"
PROMETHEUS_SERVICE_FILE="/etc/systemd/system/prometheus.service"

BLACKBOX_USER="blackbox_exporter"
BLACKBOX_GROUP="blackbox_exporter"
BLACKBOX_DIR="/usr/local/bin/blackbox_exporter-${BLACKBOX_VERSION}"
BLACKBOX_CONFIG_FILE="${BLACKBOX_DIR}/blackbox.yml"
BLACKBOX_SERVICE_FILE="/etc/systemd/system/blackbox_exporter.service"

GRAFANA_DIR="/usr/share/grafana"
GRAFANA_SERVICE_FILE="/etc/systemd/system/grafana.service"

# Install Prometheus
install_prometheus() {
  echo "Installing Prometheus..."
  wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
  tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
  sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 ${PROMETHEUS_DIR}
  sudo ln -s ${PROMETHEUS_DIR}/prometheus /usr/local/bin/prometheus
  sudo ln -s ${PROMETHEUS_DIR}/promtool /usr/local/bin/promtool

  sudo tee ${PROMETHEUS_CONFIG_FILE} > /dev/null <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOL

  sudo useradd --no-create-home --shell /bin/false ${PROMETHEUS_USER}
  sudo mkdir -p ${PROMETHEUS_DIR}/data
  sudo chown -R ${PROMETHEUS_USER}:${PROMETHEUS_GROUP} ${PROMETHEUS_DIR}

  sudo tee ${PROMETHEUS_SERVICE_FILE} > /dev/null <<EOL
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=${PROMETHEUS_USER}
Group=${PROMETHEUS_GROUP}
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=${PROMETHEUS_CONFIG_FILE} --storage.tsdb.path=${PROMETHEUS_DIR}/data

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable prometheus
  sudo systemctl start prometheus
  rm prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
  echo "Prometheus installation and setup completed."
}

# Install Blackbox Exporter
install_blackbox_exporter() {
  echo "Installing Blackbox Exporter..."
  wget https://github.com/prometheus/blackbox_exporter/releases/download/v${BLACKBOX_VERSION}/blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
  tar -xvf blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
  sudo mv blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64 ${BLACKBOX_DIR}
  sudo ln -s ${BLACKBOX_DIR}/blackbox_exporter /usr/local/bin/blackbox_exporter

  sudo tee ${BLACKBOX_CONFIG_FILE} > /dev/null <<EOL
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      valid_status_codes: []
      method: GET
      no_follow_redirects: false
      fail_if_ssl: false
      fail_if_not_ssl: false
EOL

  sudo useradd --no-create-home --shell /bin/false ${BLACKBOX_USER}
  sudo chown -R ${BLACKBOX_USER}:${BLACKBOX_GROUP} ${BLACKBOX_DIR}

  sudo tee ${BLACKBOX_SERVICE_FILE} > /dev/null <<EOL
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${BLACKBOX_USER}
Group=${BLACKBOX_GROUP}
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file=${BLACKBOX_CONFIG_FILE}

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable blackbox_exporter
  sudo systemctl start blackbox_exporter
  rm blackbox_exporter-${BLACKBOX_VERSION}.linux-amd64.tar.gz
  echo "Blackbox Exporter installation and setup completed."
}

# Install Grafana
install_grafana() {
  echo "Installing Grafana..."
  wget https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
  tar -zxvf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
  sudo mv grafana-${GRAFANA_VERSION} ${GRAFANA_DIR}

  sudo tee ${GRAFANA_SERVICE_FILE} > /dev/null <<EOL
[Unit]
Description=Grafana instance
After=network.target

[Service]
ExecStart=${GRAFANA_DIR}/bin/grafana-server web
User=root
Group=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

  sudo systemctl daemon-reload
  sudo systemctl enable grafana
  sudo systemctl start grafana
  rm grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
  echo "Grafana installation and setup completed."
}

# Run the installations
install_prometheus
install_blackbox_exporter
install_grafana

echo "Monitoring stack installation completed."



Steps to use the script
Save the script as install_monitoring_stack.sh:
nano install_monitoring_stack.sh

Make the script executable:
chmod +x install_monitoring_stack.sh

Run the script:
sudo ./install_monitoring_stack.sh

go to: sudo nano /usr/local/bin/prometheus-2.53.1/prometheus.yml
add the following code to the file:
https://github.com/prometheus/blackbox_exporter/blob/master/README.md
under Prometheus Configuration:
copy the code under the name Example config and past in prometheus.yml under scrape_configs:

past than change the ip address to blackbox under target : 52.201.178.63:9115

sudo nano /usr/local/bin/prometheus-2.53.1/prometheus.yml







