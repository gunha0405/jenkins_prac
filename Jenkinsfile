pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gunha0405/k8s_prac'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Cloning Repository'
                git branch: 'main', url: 'https://github.com/gunha0405/jenkins_prac'
            }
            post {
                success {
                    sendDiscordMessage("✅ Git Clone 성공!", "Git Repository 클론 완료", "GREEN")
                }
                failure {
                    sendDiscordMessage("❌ Git Clone 실패!", "Git Repository 클론 중 오류 발생", "RED")
                }
            }
        }

        stage('Gradle Build') {
            steps {
                echo 'Add Permission'
                sh 'chmod +x gradlew'

                echo 'Build'
                sh './gradlew bootJar'
            }
            post {
                success {
                    sendDiscordMessage("✅ Gradle Build 성공!", "Spring Boot 애플리케이션 빌드 완료", "GREEN")
                }
                failure {
                    sendDiscordMessage("❌ Gradle Build 실패!", "Gradle 빌드 중 오류 발생", "RED")
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
            post {
                success {
                    sendDiscordMessage("✅ Docker Image Build 성공!", "이미지 빌드 완료: ${IMAGE_NAME}:${IMAGE_TAG}", "GREEN")
                }
                failure {
                    sendDiscordMessage("❌ Docker Image Build 실패!", "Docker 빌드 중 오류 발생", "RED")
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'jenkins-k8s-prac']) {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
            post {
                success {
                    sendDiscordMessage("✅ Docker Image Push 성공!", "이미지 푸시 완료: ${IMAGE_NAME}:${IMAGE_TAG}", "GREEN")
                }
                failure {
                    sendDiscordMessage("❌ Docker Image Push 실패!", "Docker 이미지 푸시 중 오류 발생", "RED")
                }
            }
        }

        stage('SSH Deployment') {
            steps {
                script {
                    sshPublisher(
                        publishers: [
                            sshPublisherDesc(
                                configName: 'k8s',
                                verbose: true,
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: 'k8s/backend-deployment.yml',
                                        remoteDirectory: '/',
                                        execCommand: '''
                                            sed -i "s/latest/$BUILD_ID/g" k8s/backend-deployment.yml
                                        '''
                                    ),
                                    sshTransfer(
                                        execCommand: '''
                                            kubectl apply -f /home/test/k8s/backend-deployment.yml
                                        '''
                                    )
                                ]
                            )
                        ]
                    )
                }
            }
            post {
                success {
                    sendDiscordMessage("✅ Kubernetes 배포 성공!", "K8s Deployment 완료", "GREEN")
                }
                failure {
                    sendDiscordMessage("❌ Kubernetes 배포 실패!", "K8s Deployment 중 오류 발생", "RED")
                }
            }
        }
    }

    post {
        success {
            sendDiscordMessage("🎉 전체 파이프라인 성공!", "모든 스테이지가 정상적으로 완료되었습니다.", "GREEN")
        }
        failure {
            sendDiscordMessage("🚨 전체 파이프라인 실패!", "어떤 스테이지에서 오류가 발생했습니다. 로그를 확인하세요.", "RED")
        }
    }
}

def sendDiscordMessage(String title, String description, String color) {
    withCredentials([string(credentialsId: 'Discord-Webhook', variable: 'DISCORD')]) {
        discordSend description: description,
        footer: "Jenkins CI/CD",
        link: env.BUILD_URL,
        result: currentBuild.currentResult,
        title: title,
        color: color,
        webhookURL: "$DISCORD"
    }
}
