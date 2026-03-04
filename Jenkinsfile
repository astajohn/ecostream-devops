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
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
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
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Post Deployment Health Check') {
            steps {
                script {
                    def alb_dns = sh(
                        script: "terraform output -raw alb_dns_name",
                        returnStdout: true
                    ).trim()

                    sh """
                    echo "Waiting for ASG rolling deployment..."

                    for i in {1..20}
                    do
                        STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://${alb_dns} || true)
                        echo "Attempt \$i - HTTP Status: \$STATUS"

                        if [ "\$STATUS" = "200" ]; then
                            echo "Application is healthy!"
                            exit 0
                        fi

                        sleep 15
                    done

                    echo "Application did not become healthy in expected time."
                    exit 1
                    """
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
