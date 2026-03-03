pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ecostream:${BUILD_NUMBER} .'
            }
        }

        stage('Test') {
            steps {
                sh 'echo Running basic validation...'
            }
        }
    }
}
