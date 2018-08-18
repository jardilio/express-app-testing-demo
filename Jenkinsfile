branch_name = null
git_commit = null
job_name = null
is_releasable = null

pipeline {
    agent any

    stages {
        stage('prepare') {
            agent { docker { image 'node:6-alpine' } }
            steps {
                script {
                    branch_name = env.BRANCH_NAME ?: 'master'
                    git_commit = env.GIT_COMMIT ?: 'latest'
                    job_name = env.JOB_NAME
                    is_releasable = branch_name == 'master'
                }
                //git branch: branch_name, url: 'https://github.com/jardilio/express-app-testing-demo.git'
                sh 'rm -rf coverage/*'
                sh 'rm -rf *.tar'
                sh 'npm prune'
                sh 'npm install'
                stash name: 'app', includes: '**/*'
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
        stage('build') {
            steps {
                unstash 'app'
                sh 'ls node_modules'
                sh "docker build --compress --tag ${job_name}:${git_commit} ."
                sh "docker save ${job_name}:${git_commit} > app.tar"
            }
        }
        stage('publish') {
            when { 
                expression { is_releasable }
            }
            steps {
                unstash 'test'
                script {
                    def server = Artifactory.server 'artifactory'
                    def spec = """{
                      "files": [
                        {
                          "pattern": "*.tar",
                          "target": "${job_name}/${git_commit}/"
                        },
                        {
                          "pattern": "coverage/**",
                          "target": "${job_name}/${git_commit}/coverage/"
                        }
                     ]
                    }"""
                    server.upload(spec)
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
                    //TODO: update commit status
                }
                catch(e) {
                    echo "Error updating commit status on repo: ${e}"
                }
            }
        }
    }

}