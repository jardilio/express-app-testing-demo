is_releasable = false

pipeline {
    agent { docker { image 'node:6-alpine' } }

    stages {
        stage('prepare') {
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
            steps {
                sh 'npm run test'
                sh 'npm run test:e2e'
            }
        }
        stage('analyze') {
            steps {
                stash name: 'test', allowEmpty: false, includes: 'coverage/**'
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
                sh "docker build --compress --tag demo-app:${env.GIT_COMMIT} ."
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