/* Require installing hadolint and tidy for the linting step */

pipeline {
  environment {
    imageTag = 'bolobolobobjenkins/capstone-chatbot'
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
        sh "docker build -t ${imageTag} ."
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
        sh "docker tag ${imageTag} ${imageTag}"
        sh "docker push ${imageTag}"
      }
    }
    stage('Deploy to cluster') {
      steps {
        sh "echo 'Deploying app to cluster'"
        withAWS(credentials: 'aws-credentials', region: 'us-west-2') {
            sh "aws eks --region us-west-2 update-kubeconfig --name CapstoneCluster"
            sh "kubectl set image deployments/capstone-chatbot capstone-chatbot=bolobolobobjenkins/capstone-chatbot:latest"
        }
      }
    }
    stage('Cleaning Docker') {
      steps {
        sh "echo 'Cleaning docker'"
        sh "docker system prune -f"
      }
    }
  }
}