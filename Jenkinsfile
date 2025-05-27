pipeline {
    agent any

    environment {
        // You might define Docker Hub credentials here if not using Jenkins credentials store
        // DOCKER_HUB_USERNAME = 'your_docker_hub_username'
        // DOCKER_HUB_PASSWORD = credentials('docker-hub-credentials-id') // Replace with your Jenkins credential ID
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Get Backend Version') {
            steps {
                script {
                    def backendPackageJsonExists = fileExists 'api/package.json'
                    if (backendPackageJsonExists) {
                        def backendVersion = readJSON file: 'api/package.json'
                        env.BACKEND_VERSION = backendVersion.version
                        echo "Backend Version from api/package.json: ${env.BACKEND_VERSION}"
                    } else {
                        error "api/package.json not found."
                    }
                }
            }
        }

        stage('Build and Push Backend Image') {
            steps {
                script {
                    withEnv(["DOCKER_BUILDKIT=1"]) { // Enable BuildKit for faster builds
                        withDockerRegistry(credentialsId: 'docker-hub-mounika2608', url: 'https://registry.hub.docker.com') { // Use your Jenkins credential ID here
                            sh "docker build -t mounika2608/lms-backend:${env.BACKEND_VERSION} api"
                            sh "docker tag mounika2608/lms-backend:${env.BACKEND_VERSION} registry.hub.docker.com/mounika2608/lms-backend:${env.BACKEND_VERSION}"
                            sh "docker push registry.hub.docker.com/mounika2608/lms-backend:${env.BACKEND_VERSION}"
                            sh "docker tag mounika2608/lms-backend:${env.BACKEND_VERSION} registry.hub.docker.com/mounika2608/lms-backend:latest"
                            sh "docker push registry.hub.docker.com/mounika2608/lms-backend:latest"
                        }
                    }
                    echo "Backend image built and pushed."
                }
            }
        }

        stage('Get Frontend Version') {
            steps {
                script {
                    def frontendPackageJsonExists = fileExists 'webapp/package.json'
                    if (frontendPackageJsonExists) {
                        def frontendVersion = readJSON file: 'webapp/package.json'
                        env.FRONTEND_VERSION = frontendVersion.version
                        echo "Frontend Version from webapp/package.json: ${env.FRONTEND_VERSION}"
                    } else {
                        error "webapp/package.json not found."
                    }
                }
            }
        }

        stage('Build and Push Frontend Image') {
            steps {
                script {
                    withEnv(["DOCKER_BUILDKIT=1"]) { // Enable BuildKit
                        withDockerRegistry(credentialsId: 'docker-hub-mounika2608', url: 'https://registry.hub.docker.com') { // Use your Jenkins credential ID here
                            sh "docker build -t mounika2608/lms-frontend:${env.FRONTEND_VERSION} webapp"
                            sh "docker tag mounika2608/lms-frontend:${env.FRONTEND_VERSION} registry.hub.docker.com/mounika2608/lms-frontend:${env.FRONTEND_VERSION}"
                            sh "docker push registry.hub.docker.com/mounika2608/lms-frontend:${env.FRONTEND_VERSION}"
                            sh "docker tag mounika2608/lms-frontend:${env.FRONTEND_VERSION} registry.hub.docker.com/mounika2608/lms-frontend:latest"
                            sh "docker push registry.hub.docker.com/mounika2608/lms-frontend:latest"
                        }
                    }
                    echo "Frontend image built and pushed."
                }
            }
        }

        stage('Deploy Application with Docker Compose & Migrations') {
            steps {
                script {
                    echo "Stopping and removing any existing Docker Compose stack..."
                    sh 'docker-compose -f docker-compose.yml down --remove-orphans'

                    echo "Starting database service for migrations..."
                    sh 'docker-compose -f docker-compose.yml up -d db'

                    echo "Waiting 10 seconds for PostgreSQL to initialize..."
                    sh 'sleep 10'

                    echo "Running Prisma migrations..."
                    sh 'docker run --rm --network lms_default -e DATABASE_URL=postgresql://postgres:Qwerty@1@db:5432/mydb mounika2608/lms-backend:2.0.0 npx prisma migrate deploy'

                    echo "Prisma migrations completed."

                    // *** DEBUGGING LINES ADDED HERE ***
                    echo "Dumping docker-compose.yml content for verification:"
                    sh 'cat docker-compose.yml'
                    echo "--- End of docker-compose.yml content ---"
                    // *** END DEBUGGING LINES ***

                    echo "Bringing up the full application stack with Docker Compose..."
                    sh 'docker-compose -f docker-compose.yml up -d --remove-orphans'
                }
            }
        }
    }
    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
        failure {
            echo "Pipeline failed. Review the logs for errors."
        }
        success {
            echo "Pipeline succeeded! Application deployed."
        }
    }
}