Run these command in the EC2:
sudo apt update
sudo apt upgrade  -y


install  jenkins:

sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
java -version
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y 

sudo chmod +x jen.sh
./jen.sh

install docker

install docker and docker packages:
create file docker.sh:
sudo nano docker.sh
copy and past to setup docker:
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


sudo docker run hello-world

sudo chmod 666 /var/run/docker.sock

save and exit


sudo chmod +x docker.sh
./docker.sh

sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl status jenkins


http://100.27.108.130:8080/

setup jenkins plugin
jdk----------Eclipes terurin installer
maveb--------------------config file provider ad Pipeline Maven Integration
sonar-------------------SonarQube ScannerVersion
docker------------docker and docker Pipeline
kubernets-----------Kubernetes Client API and Kubernetes CredentialsVersion and  KubernetesVersion and Kubernete cli
aws 
