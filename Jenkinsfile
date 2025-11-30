pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-kaniko
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    env:
    - name: AWS_REGION
      value: "us-east-2"
    - name: AWS_DEFAULT_REGION
      value: "us-east-2"
  volumes:
  - name: docker-config
    configMap:
      name: docker-config
"""
        }
    }
    
    environment {
        ECR_REPOSITORY_URL = '879381271147.dkr.ecr.us-east-2.amazonaws.com/lesson-8-9-ecr'
        AWS_REGION = 'us-east-2'
        GIT_REPO_URL = 'https://github.com/asaulyak/goit-devops.git'
        GIT_BRANCH = 'main'
        HELM_CHART_PATH = 'lesson-8-9/charts/django-app'
        DOCKERFILE_PATH = 'Dockerfile'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build and Push to ECR') {
            steps {
                container('kaniko') {
                    script {
                        def imageTag = "${ECR_REPOSITORY_URL}:${BUILD_NUMBER}"
                        def imageTagLatest = "${ECR_REPOSITORY_URL}:latest"
                        
                        echo "Building Docker image from ${DOCKERFILE_PATH}..."
                        echo "Image tag: ${imageTag}"
                        echo "Image tag (latest): ${imageTagLatest}"
                        
                        sh """
                            /kaniko/executor \
                              --context . \
                              --dockerfile ${DOCKERFILE_PATH} \
                              --destination ${imageTag} \
                              --destination ${imageTagLatest} \
                              --cache=true \
                              --cache-ttl=24h \
                              --verbosity=info
                        """
                        
                        echo "✅ Successfully pushed ${imageTag} and ${imageTagLatest} to ECR"
                    }
                }
            }
        }
        
        stage('Update values.yaml') {
            steps {
                script {
                    echo "Updating Helm chart values.yaml with new image tag..."
                    
                    // Check if values.yaml exists
                    sh """
                        if [ ! -f ${HELM_CHART_PATH}/values.yaml ]; then
                            echo "Error: ${HELM_CHART_PATH}/values.yaml not found!"
                            exit 1
                        fi
                        
                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@goit-devops.local"
                        
                        # Backup original values.yaml
                        cp ${HELM_CHART_PATH}/values.yaml ${HELM_CHART_PATH}/values.yaml.bak
                        
                        # Update image repository and tag in values.yaml
                        sed -i 's|repository:.*|repository: ${ECR_REPOSITORY_URL}|g' ${HELM_CHART_PATH}/values.yaml
                        sed -i 's|tag:.*|tag: ${BUILD_NUMBER}|g' ${HELM_CHART_PATH}/values.yaml
                        
                        # Verify changes
                        echo "Updated values.yaml:"
                        grep -E "(repository|tag):" ${HELM_CHART_PATH}/values.yaml || true
                        
                        # Show diff
                        echo "Changes made:"
                        diff ${HELM_CHART_PATH}/values.yaml.bak ${HELM_CHART_PATH}/values.yaml || true
                    """
                }
            }
        }
        
        stage('Commit and Push to Git') {
            steps {
                script {
                    echo "Committing and pushing changes to Git repository..."
                    
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            # Configure git with credentials
                            git config user.name "Jenkins CI"
                            git config user.email "jenkins@goit-devops.local"
                            
                            # Update remote URL with credentials
                            git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/asaulyak/goit-devops.git
                            
                            # Add and commit changes
                            git add ${HELM_CHART_PATH}/values.yaml
                            
                            # Check if there are changes to commit
                            if git diff --staged --quiet; then
                                echo "No changes to commit"
                            else
                                git commit -m "CI: Update Django app image tag to ${BUILD_NUMBER} [skip ci]"
                                git push origin ${GIT_BRANCH}
                                echo "✅ Successfully pushed changes to ${GIT_BRANCH}"
                            fi
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline succeeded!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Image: ${ECR_REPOSITORY_URL}:${BUILD_NUMBER}"
            echo "Image (latest): ${ECR_REPOSITORY_URL}:latest"
            echo "Updated Helm chart: ${HELM_CHART_PATH}/values.yaml"
            echo "Git repository: ${GIT_REPO_URL}"
            echo "Git branch: ${GIT_BRANCH}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        }
        failure {
            echo "❌ Pipeline failed!"
            currentBuild.result = 'FAILURE'
        }
        always {
            echo "Pipeline completed with status: ${currentBuild.result}"
            // Cleanup backup file
            sh "rm -f ${HELM_CHART_PATH}/values.yaml.bak || true"
        }
    }
}

