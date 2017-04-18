env.PROJECT = 'xmatters-playground-one'
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
                git branch: env.BRANCH_NAME, url: 'https://github.com/jaredcurtis/jenkins-pipeline-demo/'
            }
        }
        stage('Bake') {
            steps {
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'make docker'
                }
            }
        }
        stage('Deploy Dev') {
            steps {
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'make deploy clean'
                }
            }
        }
        stage('Deploy Tst') {
            steps {
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    withEnv(['ENV=tst', 'REPLICAS=2']) {
                        sh 'make deploy scale clean'
                    }
                }
            }
        }
        stage('Deploy Prd') {
            when {
                expression { env.BRANCH_NAME == 'master' }
            }
            steps {
                input message: 'Deploy to production?', ok: 'We\'re all counting on you'
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    withEnv(['ENV=prd', 'REPLICAS=3']) {
                        sh 'make deploy scale clean'
                    }
                }
            }
        }
        stage('Purge') {
            steps {
                input message: 'Purge environments?'
                withCredentials([file(credentialsId: 'xmatters-playground-one', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'make purge'
                }
            }
        }
    }
}
