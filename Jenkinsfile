pipeline {
    agent any
    tools {
        maven 'maven'
    }

    environment {
        IMAGE_NAME    =  "springboot"
        IMAGE_TAG     = "latest"
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
                     docker build -t ("$IMAGE_NAME:$IMAGE_TAG") .
                }
            }
        }
    }
}
