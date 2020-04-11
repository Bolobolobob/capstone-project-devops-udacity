/* Require installing hadolint and tidy for the linting step */

pipeline {
  environment {
    imageTag = 'Bolobolobob/capstone-chatbot'
  }
  agent any
  stages {
    stage('Lint') {
      steps {
        sh "echo 'Linting'"
        sh "make lint"
      }
    }
    stage('Build Docker') {
      steps {
        sh "echo 'Building Docker image'"
        sh "sudo docker build -t ${registry} ."
      }
    }
    stage('Login to Dockerhub') {
      steps {
        sh "echo 'Login in DockerHub'"
        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
        }
      }
    }
    stage('Upload to Dockerhub'){
      steps {
        sh "echo 'Uploading to DockerHub'"
        sh "sudo docker tag ${registry} ${registry}"
        sh "docker push ${registry}"
      }
    }
    stage('Deploy to cluster') {
      steps {
        sh "echo 'Deploying app to cluster'"
        withAWS(credentials: 'aws-credentials', region: 'us-west-2') {
            sh "aws eks --region us-west-2 update-kubeconfig --name CapstoneCluster"
            sh "kubectl apply -f deployment/deployment.yml"
        }
      }
    }
    stage('Cleaning Docker') {
      steps {
        sh "echo 'Cleaning docker'"
        sh "docker system prune"
      }
    }
  }
}