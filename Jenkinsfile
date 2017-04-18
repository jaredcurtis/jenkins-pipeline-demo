pipeline {
    agent any

    stages {
        stage('Setup') {
            steps {
                deleteDir()
                sh 'gcloud components install kubectl'
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'CREDS')]) {
                    sh "gcloud auth activate-service-account --key-file=${env.CREDS}"
                }
                git branch: params.BRANCH, url: 'https://github.com/jaredcurtis/jenkins-pipeline-demo/'
            }
        }
        stage('Bake') {
            steps {
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'make docker'
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'make deploy scale'
                }
            }
        }
    }
}
