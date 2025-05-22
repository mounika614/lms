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
        string(name: 'DOCKER_REGISTRY', // New parameter for Docker registry URL
               defaultValue: 'docker.io', // Default for Docker Hub
               description: 'URL of your Docker registry (e.g., docker.io)')
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
                    // Build the Docker image
                    // Corrected line: First arg is image tag, second is build context directory
                    def dockerImage = docker.build("${params.IMAGE_NAME}:${env.VERSION}", 'webapp')
                    // Use docker.withRegistry for pushing
                    docker.withRegistry("${params.DOCKER_REGISTRY}", params.DOCKERHUB_CREDENTIALS_ID) {
                        dockerImage.push("${env.VERSION}")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Deploying image ${params.IMAGE_NAME}:${env.VERSION} using port mapping"
                    // First, stop and remove any existing container with the same name if you intend to restart it.
                    // This prevents "docker run" from failing if the container already exists.
                    sh "docker ps -a --filter 'name=lms-frontend-container' --format '{{.ID}}' | xargs -r docker rm -f"
                    sh "docker run -dt -p 80:80 --name lms-frontend-container ${params.IMAGE_NAME}:${env.VERSION}"
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