#!/bin/sh

# Prepare environment
gcloud config set compute/zone 
git clone https://github.com/GoogleCloudPlatform/continuous-deployment-on-kubernetes.git
cd continuous-deployment-on-kubernetes

gcloud container clusters create jenkins-cd \
--num-nodes 2 \
--scopes "https://www.googleapis.com/auth/projecthosting,cloud-platform"

gcloud container clusters list
gcloud container clusters get-credentials jenkins-cd
kubectl cluster-info

# Configure Helm
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Configure and install Jenkins
helm upgrade --install -f jenkins/values.yaml myjenkins jenkins/jenkins
kubectl get pods
echo http://127.0.0.1:8080
kubectl --namespace default port-forward svc/myjenkins 8080:8080 >> /dev/null &
kubectl get svc

# Connect to Jenkins
kubectl exec --namespace default -it svc/myjenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
