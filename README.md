# Capstone Project Devops Udacity

## Summary

This project is part of the Udacity Cloud Devops Engineer Nanodegree.
It aims at creating an infrastructure and a CI/CD pipeline with rolling development for an app hosted in a Kubernetes cluster.
To do this project I used the open source flask web implementation of ChatterBot developped by chamkank : https://github.com/chamkank/flask-chatterbot

The app is currently available at this address : http://a32c6e15c7fe511ea8bf502b4def2ddd-1186078379.us-west-2.elb.amazonaws.com/
## Infrastructure

The following infrastructure is deployed :

![Chart of infrastructure](https://github.com/Bolobolobob/capstone-project-devops-udacity/blob/master/CapstoneChart.jpeg)

## Workflow

When an update is pushed to the github repository, Jenkins runs the pipeline :
* The code is linted
* A docker image is built
* The docker image is pushed to DockerHub
* The deployment image of the EKS cluster is updated using a rolling update

## Screenshots

In the screenshot folder the following screenshots are provided :
* lint_fail_screenshot.PNG shows how the Jenkins pipeline fails when there is an error in the code
* successful_lint.PNG shows on the other hand how the pipeline successfuly completes when there is no linting error
* rollout_screenshot.PNG shows how the pods are correctly replaced during a rolling update : we can first see all the pods running, then an update occurs and the pods are replaced following the rolling update policy, and finaly the status of the update is successful

## Installation

### Deploying the infrastructure

To deploy the infrastucture you must first ensure that you have the AWS CLI installed and configured with the required permissions to create the infrastructure.

All the files for deploying the infrastructure are in the infrastructure folder.

You will need to deploy :
1. The network (network.yml) composed of the VPC, the subnets, the NAT Gateways, the internet gateway...
2. The cluster (cluster.yml) composed of the control plane, the managed node groups...
3. The jenkins instance (jenkins.yml) that creates an instance where jenkins and all its required dependencies are installed
4. (Optional) A bastion (bastion.yml) if you want to connect to your nodes

Before creating the cluster you must ensure that you finished creating the network.

To deploy these stacks you can use the create.bat and update.bat scripts (for windows) as follows :

`./create.bat stack-name stack-file.yml stack_parameters-file.json`

Alternatively you can use :

```
aws cloudformation create-stack --stack-name %1 --template-body file://stack-file.yml  --parameters file://stack_parameters-file.json --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region=region-name
```

### Creating a Kubernetes deployment

To create a deployment you need to do : `kubectl apply -f deployment/deployment.yml` after the infrastructure has been correctly deployed.
After that, the CI/CD pipeline will automatically update your deployment using rolling updates.

If you don't want to use the CI/CD pipeline and Jenkins, you can deploy directly the app to the cluster you just created. For that you will need :

1. To build an image of the app : `docker build -t image-tag .`
2. Login and push it to your container repo. For instance with DockerHub :
```
docker login -u username -p password
docker tag image-tag image-tag
docker push image-tag
```
3. Create a deployment :
```
aws eks --region region-name update-kubeconfig --name CapstoneCluster
kubectl apply -f deployment/deployment.yml
```

### Creating a CI/CD pipeline with Jenkins

If you want to use Jenkins, after creating the Jenkins instance you will need to configure it.
You will need the following plugins :

* BlueOcean (Optional)
* Pipeline AWS

After creating the pipeline, your app should be automatically uploaded to the EKS cluster.

### Running the app locally

Alternatively you can also run the app on your own computer without using a kubernetes cluster.

For that I advise to create you own virtual environment using `make setup`and then connecting to it using `source ~/.flaskapp/bin/activate`.
You can then install the required dependencies using `make install`.
Then you just need to run `uwsgi --http 0.0.0.0:5000 --wsgi-file flask_app/app.py --callable app --processes 4 --threads 1` to launch the app.

