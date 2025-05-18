pipeline {
    agent any
    parameters {
        string(name: 'DOCKERHUB_CREDENTIALS_ID',
               defaultValue: 'dockerhub',  // Use the ID you provided
               description: 'ID of the Docker Hub credentials in Jenkins')
        string(name: 'DOCKERHUB_USERNAME',
               defaultValue: 'mounika2608',
               description: 'Your Docker Hub username')
        string(name: 'IMAGE_NAME',
               defaultValue: 'mounika2608/lms-frontend',
               description: 'Name of the Docker image in Docker Hub')
    }
    stages {
        stage('Version') {
            steps {
                script {
                    def packageJson = readJSON file: 'webapp/package.json'
                    env.VERSION = packageJson.version
                    echo "Version from package.json: ${env.VERSION}"
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                    dockerLogin(credentialsId: params.DOCKERHUB_CREDENTIALS_ID,
                                username: params.DOCKERHUB_USERNAME)
                    def dockerImage = docker.build("${params.IMAGE_NAME}:${env.VERSION}", dir: 'webapp')
                    // Tag the image for Docker Hub
                    dockerImage.push("${env.VERSION}")
                    dockerImage.push('latest')
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying image ${params.IMAGE_NAME}:${env.VERSION} using port mapping"
                    sh "docker run -dt -p 80:80 ${params.IMAGE_NAME}:${env.VERSION}"
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}