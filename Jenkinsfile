pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER = 'content-platform-cluster'
        AWS_ACCOUNT_ID = '975373241855'
        BACKEND_IMAGE = 'content-platform-backend'
        FRONTEND_IMAGE = 'content-platform-frontend'
        VERSION = 'latest'
        S3_BUCKET = 'content-platform-logs-bucket'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        BACKEND_ECR_REPO = "${ECR_REGISTRY}/${BACKEND_IMAGE}"
        FRONTEND_ECR_REPO = "${ECR_REGISTRY}/${FRONTEND_IMAGE}"
        BACKEND_SERVICE_NAME = 'content-platform-backend-service'
        FRONTEND_SERVICE_NAME = 'content-platform-frontend-service'
        K8S_NAMESPACE = 'default'
    }

    options {
        timeout(time: 45, unit: 'MINUTES')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/your-repo/content-platform.git', branch: 'main'
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'chmod +x mvnw || true'
                    sh './mvnw clean package -Dmaven.test.skip=true'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar, **/build/**', fingerprint: true
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Backend Image') {
                    steps {
                        dir('backend') {
                            sh "docker build -t ${BACKEND_IMAGE}:${VERSION} ."
                        }
                    }
                }
                stage('Build Frontend Image') {
                    steps {
                        dir('frontend') {
                            sh "docker build -t ${FRONTEND_IMAGE}:${VERSION} ."
                        }
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    sh '''
                    set -e
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

                    # Create repositories if they don't exist
                    for repo in $BACKEND_IMAGE $FRONTEND_IMAGE; do
                        if ! aws ecr describe-repositories --repository-names $repo > /dev/null 2>&1; then
                            aws ecr create-repository --repository-name $repo
                        fi
                    done

                    # Tag and push images
                    docker tag $BACKEND_IMAGE:$VERSION $BACKEND_ECR_REPO:$VERSION
                    docker push $BACKEND_ECR_REPO:$VERSION
                    
                    docker tag $FRONTEND_IMAGE:$VERSION $FRONTEND_ECR_REPO:$VERSION
                    docker push $FRONTEND_ECR_REPO:$VERSION
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    sh '''
                    export KUBECONFIG=$(mktemp)
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER --kubeconfig $KUBECONFIG

                    kubectl --kubeconfig $KUBECONFIG apply -f k8s/database-deployment.yml
                    kubectl --kubeconfig $KUBECONFIG apply -f k8s/backend-deployment.yml
                    kubectl --kubeconfig $KUBECONFIG apply -f k8s/backend-service.yml
                    kubectl --kubeconfig $KUBECONFIG apply -f k8s/frontend-deployment.yml
                    kubectl --kubeconfig $KUBECONFIG apply -f k8s/frontend-service.yml
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    script {
                        sh '''
                        export KUBECONFIG=$(mktemp)
                        aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER --kubeconfig $KUBECONFIG
                        echo "Running smoke test..."

                        for i in $(seq 1 10); do
                          HOST=$(kubectl --kubeconfig $KUBECONFIG get svc $FRONTEND_SERVICE_NAME -n $K8S_NAMESPACE -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null)
                          if [ -n "$HOST" ]; then
                            echo "LoadBalancer hostname: $HOST"
                            break
                          fi
                          echo "Waiting for LoadBalancer IP... ($i)"
                          sleep 30
                        done

                        if [ -z "$HOST" ]; then
                          echo "LoadBalancer hostname not available. Smoke test failed."
                          exit 1
                        fi

                        curl -sSf http://$HOST:80/ | grep -i "content platform" || {
                          echo "Smoke test failed: Frontend not responding correctly"
                          exit 1
                        }
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
        always {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                sh '''
                export KUBECONFIG=$(mktemp)
                aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER --kubeconfig $KUBECONFIG

                echo "Pipeline completed at $(date)" > pipeline.log
                echo "Pods status:" >> pipeline.log
                kubectl --kubeconfig $KUBECONFIG get pods -n $K8S_NAMESPACE >> pipeline.log
                echo "Services status:" >> pipeline.log
                kubectl --kubeconfig $KUBECONFIG get svc -n $K8S_NAMESPACE >> pipeline.log

                aws s3 cp pipeline.log s3://$S3_BUCKET/logs/pipeline-$(date +%Y%m%d%H%M%S).log
                '''
            }
        }
    }
}