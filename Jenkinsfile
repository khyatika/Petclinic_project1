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
    }
}
