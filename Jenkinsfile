#!groovy​
pipeline {
    agent any
    stages {
        stage('clean') {
            agent { docker { image 'node:6-alpine' } }
            steps {
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
                parallel(
                    lint: {
                        unstash 'clean'
                        sh 'npm run lint'
                        stash name: 'test', includes: 'coverage/**'
                    },
                    unit: {
                        unstash 'clean'
                        sh 'npm run jest'
                        stash name: 'test', includes: 'coverage/**'
                    },
                    e2e: {
                        unstash 'clean'
                        sh 'npm run test:e2e'
                        stash name: 'test', includes: 'coverage/**'
                    }
                )
            }
        }
        stage('analyze') {
            steps {
                unstash 'clean'
                unstash 'test'
                junit testResults: "coverage/junit-*.xml"
                step([
                    $class: 'CloverPublisher',
                    cloverReportDir: 'coverage',
                    cloverReportFileName: 'clover.xml'
                ])
                script {
                    devops.pushSonarQube(this)
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
                unstash 'build'
                script {
                    devops.pushArtifactory(this, ["app.image.tar"])
                }
            }
        }
    }
    post {
        cleanup {
            script {
                devops.pushNotifications(this)
            }
        }
    }
}