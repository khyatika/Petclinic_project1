pipeline {
    agent any
    tools {
        maven 'maven'
    }

    environment {
        IMAGE_NAME    =  "springboot"
        IMAGE_TAG     = "latest"
        TENANT_ID     = "f46e6d7b-1a04-483f-85ed-4069b0e44659"
        ACR_NAME      =  "dockerregnodejsw"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        FULL_IMAGE_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
        RESOURCE_GROUP  = "DemoAKS"
        CLUSTER_NAME = "demo-eks"
    }
    stages {
        stage('Checkout From Git') {
            steps {
                git branch: 'main', url: 'https://github.com/khyatika/Petclinic_project1.git'
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
                    -Dsonar.organization=khyatika \
                    -Dsonar.projectName=Penclinic \
                    -Dsonar.projectKey=khyatika_penclinic \
                    -Dsonar.java.binaries=. \
                    -Dsonar.exclusions=**/trivy-report.txt
                    '''
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
                withCredentials([usernamePassword(credentialsId: 'azure_login', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
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

        stage('Jenkins Login to Kubernetes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure_login', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    script {
                        sh '''
                        echo "Jenkins Login to Azure and Kubernetes"
                        az login --service-principal -u $AZURE_USERNAME -p $AZURE_PASSWORD --tenant $TENANT_ID
                        az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
                        '''
                    }
                 }
            }
        }

        stage('Deploy to kubernetes') {
            steps {
                script {
                    echo 'Deploy to Kubernetes'
                    sh '''
                    kubectl apply -f k8s/sprinboot-deployment.yaml         
                    echo 'Deployed to Kubernetes'
                    '''
                }
            }
        }
    }
}
