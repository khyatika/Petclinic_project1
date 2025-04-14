pipeline {
    agent any
    tools {
        maven 'maven' // Ensure the Maven installation name matches the one configured in Jenkins 
    }
    environment {
        IMAGE_NAME = "springbootapp"
        IMAGE_TAG = "${BUILD_NUMBER}" // Use build number as version
        ACR_NAME = "jenkinsazure"
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        FULL_IMAGE_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
        TENANT_ID = "ec78375d-0db0-42cf-82a6-2e6403e95936"
        RESOURCE_GROUP = "Jenkins"
        AKS_CLUSTER = "springboot"
        K8S_NAMESPACE = "default"
        K8S_DEPLOYMENT = "springboot-app"
    }

    stages {
        stage('Checkout From Git') {
            steps {
                git branch: 'prod', url: 'https://github.com/bkrrajmali/enahanced-petclinc-springboot.git'
            }
        }

        stage('Maven Compile') {
            steps {
                echo "This is Maven Compile Stage"
                sh 'mvn compile'
            }
        }

        stage('Maven Test') {
            steps {
                echo "This is Maven Test Stage"
                sh 'mvn test'
            }
        }

        stage('File System Scan By Trivy') {
            steps {
                echo "Trivy Scan Started"
                sh 'trivy fs --format table --output trivy-report.txt --severity HIGH,CRITICAL .'
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
                    -Dsonar.exclusions=**/trivy-fs-output.txt
                    '''
                }
            }
        }
        stage('Sonar Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
                }
            }
        }
        stage('Maven Package') {
            steps {
                echo "Maven Package Started"
                sh 'mvn package'
            }
        }
    }
}