PROJECT DOCUMENTATION

SERVERS PROVISIONED
===========================================================================
- Jenkins
- Kubernetes
- Sonarqube

1. Goto AWS Account, login
2. Goto EC2
3. Create a Security Group 
	Inbound rule
		- expose all traffic from anywhere IPV4 to allow traffic to/from server
		- expose SSH on port 22 to allow you communicate with your server.
	Save and exit

4. Spin up server with following configuration
	RedHat v8 or Ubuntu
	t2.medium

	select existing Security group - (No 3) under Network
	default on others
	Launch the instance

5. SSH into the instances after lauching it.


INSTALLATIONS
===========================================================================
JENKINS (Ubuntu)
============================================================================================
(Install Docker on Jenkins server so that Jenkins can run Dcoker commands)

Default port :8080


#!/bin/bash

sudo apt update -y
sudo apt install openjdk-11-jre -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt install gnupg2 pass
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo group add docker
sudo groupadd jenkins
sudo usermod -aG docker jenkins 
sudo chown jenkins:jenkins /var/run/docker.sock
sudo systemctl restart docker
sudo systemctl restart jenkins
sudo systemctl enable docker
sudo systemctl status jenkins


#Also install kubectl on jenkins server and copy the kubernetes configuration file (.kube/config) to jenkin so that it can communicate to kubernetes and run kubernetes commands

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
kubectl version --client


============================================================================================

KUBERNETES (Ubuntu)
============================================================================================
#!/bin/bash

sudo cat <<EOF | sudo tee /etc/hosts
<Your privateIP> master
EOF

sudo apt update -y

sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sudo echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo swapoff -a  
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab 

sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF


sudo cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt update -y
wget https://github.com/containerd/containerd/releases/download/v1.6.8/containerd-1.6.8-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.6.8-linux-amd64.tar.gz
wget wget https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl daemon-reload
sudo systemctl start kubelet
sudo systemctl enable kubelet.service


sudo kubeadm init 
#follow the instruction after running (sudo kubeadm init)

mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#weave network
sudo kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


===============================================================================================================

SONARQUBE (Redhat)
===============================================================================================================
t2 medium
Default port 9000
sudo hostname sonar
cd /opt
sudo yum -y install unzip wget git
sudo wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm
sudo yum install jdk-8u131-linux-x64.rpm -y
#Download the SonarQube Server software. 
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.8.zip
sudo unzip sonarqube-7.8.zip
sudo rm -rf sonarqube-7.8.zip
sudo mv sonarqube-7.8 sonarqube


#As a good security practice, SonarQube Server is not advised to run sonar service as a root user, 
so create a new user called sonar and grant sudo access to manage sonar services as follows

sudo useradd sonar

# Grant sudo access to sonar user

sudo echo "sonar ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sonar

sudo chown -R sonar:sonar /opt/sonarqube/
sudo chmod -R 775 /opt/sonarqube/

# start sonarqube as sonar user using relative path
sudo su - sonar  
cd /opt/sonarqube/bin/linux-x86-64/ 
sh sonar.sh start
# or start sonarqube as sonar user using absolute path
sh /opt/sonarqube/bin/linux-x86-64/sonar.sh start 

=====================================================================================================================
 
SETUPS
=======
JENKINS

- Launch Jenkins on the browser <PublicIP:8080>
- sudo cat /var/lib/jenkins/secrets/initialAdminPassword will print the password at console.
- Install the Plugins
- Create you login credentials and login

SONARQUBE

- Launch Sonarqube on the browser <PublicIP:9000>
- Default Login (username - admin , password - admin)
- Edit the pom.xml file from the repo in github to include the sonarqube privateIP:port
	<properties>
		<sonar.host.url>http://<sonarqubeprivateIP>:9000/</sonar.host.url>
	</properties>
	
======================================================================================================================

JOB
=====
- click on new item and create your pipeline (Groovy script)
- Run the pipeline by clicking (Build Now)
- jobend