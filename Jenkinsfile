pipeline {
    agent any
    tools {
        maven 'maven'
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
                sh " mvn compile"
            }
        }
        stage('Maven Test') {
            steps {
                echo "This is Maven Test Stage"
                sh " mvn test"
            }
        }
        stage('File Scanning by Trivy') {
            steps {
                echo "Trivy Scanning"
                sh  'trivy fs --format table --output trivy-report.txt --severity HIGH,CRITICAL .'
            }
        }
    }
}
