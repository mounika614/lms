pipeline {
    agent any
    parameters {
        string(name: 'DOCKERHUB_CREDENTIALS_ID',
               defaultValue: 'dockerhub',
               description: 'ID of the Docker Hub credentials in Jenkins')
        string(name: 'DOCKERHUB_USERNAME',
               defaultValue: 'mounika2608',
               description: 'Your Docker Hub username')
        string(name: 'DOCKER_REGISTRY',
               defaultValue: 'https://registry.hub.docker.com',
               description: 'URL of your Docker registry (e.g., https://registry.hub.docker.com)')
    }
    stages {
        // This stage is crucial for cloning your repository.
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Get Backend Version') {
            steps {
                script {
                    // Corrected path for backend package.json
                    def packageJsonPath = 'api/package.json'
                    if (fileExists(packageJsonPath)) {
                        def packageJson = readJSON file: packageJsonPath
                        env.BACKEND_VERSION = packageJson.version // Unique variable for backend
                        echo "Backend Version from ${packageJsonPath}: ${env.BACKEND_VERSION}"
                    } else {
                        error "Backend package.json not found at ${packageJsonPath}"
                    }
                }
            }
        }
        stage('Build and Push Backend Image') {
            steps {
                script {
                    // Login to Docker Hub before building/pushing
                    docker.withRegistry("${params.DOCKER_REGISTRY}", params.DOCKERHUB_CREDENTIALS_ID) {
                        // Build the Docker image
                        def backendImageName = "${params.DOCKERHUB_USERNAME}/lms-backend"
                        def dockerImage = docker.build("${backendImageName}:${env.BACKEND_VERSION}", 'api')
                        // Push with specific version tag
                        dockerImage.push("${env.BACKEND_VERSION}")
                        // Also push with the 'latest' tag, as docker-compose.yml uses 'latest'
                        dockerImage.push('latest')
                    }
                    echo "Backend image built and pushed."
                }
            }
        }
        stage('Get Frontend Version') {
            steps {
                script {
                    def packageJsonPath = 'webapp/package.json'
                    if (fileExists(packageJsonPath)) {
                        def packageJson = readJSON file: packageJsonPath
                        env.FRONTEND_VERSION = packageJson.version // Unique variable for frontend
                        echo "Frontend Version from ${packageJsonPath}: ${env.FRONTEND_VERSION}"
                    } else {
                        error "Frontend package.json not found at ${packageJsonPath}"
                    }
                }
            }
        }
        stage('Build and Push Frontend Image') {
            steps {
                script {
                    // Login to Docker Hub before building/pushing
                    docker.withRegistry("${params.DOCKER_REGISTRY}", params.DOCKERHUB_CREDENTIALS_ID) {
                        // Build the Docker image
                        def frontendImageName = "${params.DOCKERHUB_USERNAME}/lms-frontend"
                        def dockerImage = docker.build("${frontendImageName}:${env.FRONTEND_VERSION}", 'webapp')
                        // Push with specific version tag
                        dockerImage.push("${env.FRONTEND_VERSION}")
                        // Also push with the 'latest' tag, as docker-compose.yml uses 'latest'
                        dockerImage.push('latest')
                    }
                    echo "Frontend image built and pushed."
                }
            }
        }
        stage('Deploy Application with Docker Compose & Migrations') {
            steps {
                script {
                    // Clean up any previous Docker Compose stack to ensure a fresh start
                    echo "Stopping and removing any existing Docker Compose stack..."
                    // Adding || true to prevent pipeline failure if no containers exist to stop
                    sh "docker-compose -f docker-compose.yml down --remove-orphans || true"
                    // Start only the database service (no migration step here now)
                    echo "Starting database service..." // Changed message
                    sh "docker-compose -f docker-compose.yml up -d db"
                    // Give the database a moment to fully initialize (important without healthcheck)
                    echo "Waiting 10 seconds for PostgreSQL to initialize..."
                    sh "sleep 10"
                    // Removed: Running Prisma migrations...
                    // Removed: sh "docker run --rm --network lms_default -e DATABASE_URL=..."
                    // Removed: echo "Prisma migrations completed."

                    // === START DEBUGGING ADDITION ===
                    echo "Dumping docker-compose.yml content for verification:"
                    sh 'cat docker-compose.yml'
                    echo "--- End of docker-compose.yml content ---"
                    // === END DEBUGGING ADDITION ===
                    // Now, bring up the entire application stack using Docker Compose
                    echo "Bringing up the full application stack with Docker Compose..."
                    // Docker Compose will pull the 'latest' images you just pushed
                    sh "docker-compose -f docker-compose.yml up -d --remove-orphans"
                    echo "Application deployed successfully!"
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