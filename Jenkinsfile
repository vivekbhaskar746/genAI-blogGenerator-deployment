pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '488279420670'
        BACKEND_IMAGE = 'content-platform-backend'
        FRONTEND_IMAGE = 'content-platform-frontend'
        VERSION = 'latest'
        S3_BUCKET = 'content-platform-logs-bucket'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        BACKEND_ECR_REPO = "${ECR_REGISTRY}/${BACKEND_IMAGE}"
        FRONTEND_ECR_REPO = "${ECR_REGISTRY}/${FRONTEND_IMAGE}"
        ECS_CLUSTER = 'content-platform-ecs-cluster'
        BACKEND_SERVICE_NAME = 'content-platform-backend-service'
        FRONTEND_SERVICE_NAME = 'content-platform-frontend-service'
    }

    options {
        timeout(time: 45, unit: 'MINUTES')
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/vivekbhaskar746/genAI-blogGenerator-deployment.git', branch: 'main'
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -Dmaven.test.skip=true'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                    sh 'CI=false npm run build'
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

                    for repo in $BACKEND_IMAGE $FRONTEND_IMAGE; do
                        if ! aws ecr describe-repositories --repository-names $repo > /dev/null 2>&1; then
                            aws ecr create-repository --repository-name $repo
                        fi
                    done

                    docker tag $BACKEND_IMAGE:$VERSION $BACKEND_ECR_REPO:$VERSION
                    docker push $BACKEND_ECR_REPO:$VERSION

                    docker tag $FRONTEND_IMAGE:$VERSION $FRONTEND_ECR_REPO:$VERSION
                    docker push $FRONTEND_ECR_REPO:$VERSION
                    '''
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    sh '''
                    set -e

                    # Update backend task definition
                    BACKEND_TASK_DEF=$(aws ecs describe-task-definition --task-definition $BACKEND_SERVICE_NAME)
                    BACKEND_NEW_DEF=$(echo $BACKEND_TASK_DEF | jq --arg IMAGE "$BACKEND_ECR_REPO:$VERSION" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | {family: .family, containerDefinitions: .containerDefinitions, executionRoleArn: .executionRoleArn, networkMode: .networkMode, requiresCompatibilities: .requiresCompatibilities, cpu: .cpu, memory: .memory}')
                    BACKEND_REVISION=$(aws ecs register-task-definition --cli-input-json "$BACKEND_NEW_DEF" | jq -r '.taskDefinition.taskDefinitionArn')
                    aws ecs update-service --cluster $ECS_CLUSTER --service $BACKEND_SERVICE_NAME --task-definition $BACKEND_REVISION

                    # Update frontend task definition
                    FRONTEND_TASK_DEF=$(aws ecs describe-task-definition --task-definition $FRONTEND_SERVICE_NAME)
                    FRONTEND_NEW_DEF=$(echo $FRONTEND_TASK_DEF | jq --arg IMAGE "$FRONTEND_ECR_REPO:$VERSION" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | {family: .family, containerDefinitions: .containerDefinitions, executionRoleArn: .executionRoleArn, networkMode: .networkMode, requiresCompatibilities: .requiresCompatibilities, cpu: .cpu, memory: .memory}')
                    FRONTEND_REVISION=$(aws ecs register-task-definition --cli-input-json "$FRONTEND_NEW_DEF" | jq -r '.taskDefinition.taskDefinitionArn')
                    aws ecs update-service --cluster $ECS_CLUSTER --service $FRONTEND_SERVICE_NAME --task-definition $FRONTEND_REVISION
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                echo '🧪 ECS smoke test placeholder — implement health check if needed.'
            }
        }
    }

    post {
        always {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                sh '''
                set -e
                echo "Pipeline completed at $(date)" > pipeline.log
                echo "ECS deployment complete." >> pipeline.log
                aws s3 cp pipeline.log s3://$S3_BUCKET/logs/pipeline-$(date +%Y%m%d%H%M%S).log
                '''
            }
        }
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
