pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gunha0405/k8s_prac'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Cloneing Repository'
                git branch : 'main', url: 'https://github.com/gunha0405/jenkins_prac'
            }
        }
        stage('Gradle Build') {
            steps {
                echo 'Add Permission'
                sh 'chmod +x gradlew'

                echo 'Build'
                sh './gradlew bootJar'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
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
        }
        stage('SSH') {
                     steps{
                         script{
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
                 }

    }
}
