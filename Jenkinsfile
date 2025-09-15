pipeline {
    agent { label 'Docker-Server' }

    environment {
        NOTES_APP_IMAGE_NAME = "notes-app"
        NGINX_IMAGE = "nginx"
    }

    stages {
        stage("Clone Repository") {
            steps {
                echo "📥 Cloning the repository..."
                cleanWs()
                git branch: 'main', url: 'https://github.com/PSBHURE/Notes-app.git'
            }
        }

        stage("Read & Increment Version") {
            steps {
                dir("django-notes-app") {
                    script {
                        def versionFile = 'version.txt'
                        def version = readFile(versionFile).trim()
                        echo "🔢 Current Version: ${version}"

                        // Increment patch version
                        def (major, minor, patch) = version.tokenize('.')
                        patch = patch.toInteger() + 1
                        env.NEW_VERSION = "${major}.${minor}.${patch}"
                        echo "📈 New Version: ${env.NEW_VERSION}"

                        // Save new version back to file
                        writeFile file: versionFile, text: env.NEW_VERSION

                        // Stage and commit updated version.txt
                        sh """
                            git config user.email "jenkins@localhost"
                            git config user.name "Jenkins"
                            git add ${versionFile}
                            git commit -m "🔖 Update version to ${env.NEW_VERSION}"
                            git push origin main
                        """
                    }
                }
            }
        }

        stage("Build Docker Image") {
            steps {
                echo "🐳 Building Docker image..."
                dir("django-notes-app") {
                    sh "docker build -t ${NOTES_APP_IMAGE_NAME}:${env.NEW_VERSION} -t ${NOTES_APP_IMAGE_NAME}:latest ."
                }
                dir("django-notes-app/nginx") {
                    sh "docker build -t ${NGINX_IMAGE}:${env.NEW_VERSION} -t ${NGINX_IMAGE}:latest ."
                }
            }
        }

        stage("Push to DockerHub") {
            steps {
                echo "📦 Pushing image to DockerHub..."
                script {
                    withCredentials([usernamePassword(
                        credentialsId: "DockerHubCred",
                        usernameVariable: "DockerHubUser",
                        passwordVariable: "DockerHubPass"
                    )]) {
                        sh """
                            docker login -u $DockerHubUser -p $DockerHubPass

                            docker tag ${NOTES_APP_IMAGE_NAME}:${env.NEW_VERSION} $DockerHubUser/${NOTES_APP_IMAGE_NAME}:${env.NEW_VERSION}
                            docker tag ${NOTES_APP_IMAGE_NAME}:latest $DockerHubUser/${NOTES_APP_IMAGE_NAME}:latest
                            docker push $DockerHubUser/${NOTES_APP_IMAGE_NAME}:${env.NEW_VERSION}
                            docker push $DockerHubUser/${NOTES_APP_IMAGE_NAME}:latest

                            docker tag ${NGINX_IMAGE}:${env.NEW_VERSION} $DockerHubUser/${NGINX_IMAGE}:${env.NEW_VERSION}
                            docker tag ${NGINX_IMAGE}:latest $DockerHubUser/${NGINX_IMAGE}:latest
                            docker push $DockerHubUser/${NGINX_IMAGE}:${env.NEW_VERSION}
                            docker push $DockerHubUser/${NGINX_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage("Success Feedback") {
            steps {
                echo "✅ Jenkins pipeline completed successfully! Version: ${env.NEW_VERSION}"
            }
        }
    }
}
