is_releasable = false

pipeline {
    agent any

    stages {
        stage('prepare') {
            agent { docker { image 'node:6-alpine' } }
            steps {
                sh 'rm -rf coverage/*'
                sh 'npm prune'
                sh 'npm install'
                script {
                    is_releasable = env.BRANCH_NAME == 'master'
                }
            }
        }
        stage('test') {
            agent { docker { image 'node:6-alpine' } }
            steps {
                sh 'npm run test'
                sh 'npm run test:e2e'
                stash name: 'test', allowEmpty: false, includes: 'coverage/**'
            }
        }
        stage('analyze') {
            steps {
                unstash 'test'
                junit testResults: 'coverage/junit-*.xml'
                step([
                    $class: 'CloverPublisher',
                    cloverReportDir: 'coverage',
                    cloverReportFileName: 'clover.xml',
                    healthyTarget: [methodCoverage: 70, conditionalCoverage: 80, statementCoverage: 80],
                    unhealthyTarget: [methodCoverage: 50, conditionalCoverage: 50, statementCoverage: 50],
                    failingTarget: [methodCoverage: 0, conditionalCoverage: 0, statementCoverage: 0]
                ])
            }
        }
        stage('package') {
            when { 
                expression { is_releasable }
            }
            steps {
                script {
                    docker.withRegistry('http://artifactory:8081', 'artifactory-credentials-id') {
                        docker.build("${env.JOB_NAME}:${env.GIT_COMMIT}")//.push()
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                currentBuild.result = 'SUCCESS';
            }
        }
        cleanup {
            script {
                try {
                    //notifyBitbucket()
                }
                catch(e) {
                    echo "Error updating commit status on repo: ${e}"
                }
            }
        }
    }

}