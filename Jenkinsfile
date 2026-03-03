pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        TF_WORKSPACE = "${env.BRANCH_NAME == 'main' ? 'prod' : 'dev'}"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init -input=false
                    '''
                }
            }
        }

        stage('Select or Create Workspace') {
            steps {
                dir('terraform') {
                    sh """
                    terraform workspace select ${TF_WORKSPACE} || terraform workspace new ${TF_WORKSPACE}
                    """
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval (Production Only)') {
            when {
                branch 'main'
            }
            steps {
                input message: "Approve deployment to PRODUCTION?", ok: "Deploy"
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Post Deployment Health Check') {
            steps {
                dir('terraform') {
                    script {
                        def alb_dns = sh(
                            script: "terraform output -raw alb_dns_name",
                            returnStdout: true
                        ).trim()

                        sh """
                        echo "Waiting for ASG rolling deployment..."
                        sleep 90
                        echo "Checking ALB: http://${alb_dns}"
                        curl -f http://${alb_dns}
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
