pipeline {
    agent any
    tools {
        maven 'maven'
    }

    environment {
        IMAGE_NAME    =  "springboot"
        IMAGE_TAG     = "latest"
        TENANT_ID     = "ec78375d-0db0-42cf-82a6-2e6403e95936"
        ACR_NAME      =  "dockerregnodejs"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        FULL_IMAGE_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    stages {
        stage('Checkout From Git') {
            steps {
                git branch: 'prod', url: 'https://github.com/bkrrajmali/enahanced-petclinc-springboot.git'
            }
        }
        stage('Maven Compile') {
            steps {
                echo 'This is Maven Compile Stage'
                sh 'mvn compile'
            }
        }
        stage('Maven Test') {
            steps {
                echo 'This is Maven Test Stage'
                sh 'mvn test'
            }
        }
        stage('File Scanning by Trivy') {
            steps {
                echo 'Trivy Scanning'
                sh  'trivy fs --format table --output trivy-report.txt --severity HIGH,CRITICAL .'
            }
        }
        stage('Sonar Analysis') {
            environment {
                SCANNER_HOME = tool 'Sonar-scanner'
            }
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.organization=bkrrajmali \
                    -Dsonar.projectName=SpringBootPet \
                    -Dsonar.projectKey=bkrrajmali_springbootpet \
                    -Dsonar.java.binaries=. \
                    -Dsonar.exclusions=**/trivy-report.txt
                    '''
                }
            }
        }
        stage('Quality Gate'){
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
          }
        }
      }
        stage('Maven Package') {
            steps {
                echo 'This is Maven Package Stage'
                sh 'mvn package'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                     echo 'Docker Build Started'
                     docker.build ("$IMAGE_NAME:$IMAGE_TAG")
                }
            }
        }
        stage('Azure Login to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azurespn', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    script {
                        echo 'Azure Login '
                        sh '''
                        az login  --service-principal -u $AZURE_USERNAME -p $AZURE_PASSWORD --tenant $TENANT_ID
                        az acr login --name $ACR_NAME

                        '''
                    }
                }
        }
    }
    stage('Docker Push') {
            steps {
                script {
                     echo 'Docker Push Started'
                        sh '''
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}
                            docker push ${FULL_IMAGE_NAME}
                     '''
                }
            }
        }
    }
}
