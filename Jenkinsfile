#!groovy​
pipeline {
    agent any
    stages {
        stage('clean') {
            agent { docker { image 'node:6-alpine' } }
            steps {
                //git 'https://github.com/jardilio/express-app-testing-demo.git'
                sh 'rm -rf *.image.tar'
                sh 'rm -rf coverage/*'
                sh 'npm prune'
                sh 'npm install'
                stash name: 'clean', includes: '**/*'
            }
        }
        stage('test') {
            agent { docker { image 'node:6-alpine' } }
            steps {
                sh 'npm run test'
                sh 'npm run test:e2e'
                stash name: 'test', includes: 'coverage/**'
            }
        }
        stage('analyze') {
            steps {
                unstash 'clean'
                unstash 'test'
                script {
                    doiab.pushSonarQube(this)
                }
            }
        }
        stage('build') {
            steps {
                unstash 'clean'
                sh "docker build --compress --tag app:latest ."
                sh "docker save app:latest > app.image.tar"
                stash name: 'build', includes: 'app.image.tar'
            }
        }
        stage('publish') {
            steps {
                unstash 'test'
                unstash 'build'
                script {
                    doiab.pushArtifactory(this, ["app.image.tar"])
                }
            }
        }
    }
    post {
        cleanup {
            script {
                doiab.pushNotifications(this)
            }
        }
    }
}