pipeline {
    agent any
    stages {
        stage('Checkout From Git') {
            steps {
                git branch: 'prod', url: 'https://github.com/bkrrajmali/enahanced-petclinc-springboot.git'
            }
        }
        stage('Test') {
            steps {
                echo "Test1"
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploy1"
            }
        }
    }
}
