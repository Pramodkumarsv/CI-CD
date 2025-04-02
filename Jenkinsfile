pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://10.20.42.99:9000/'
        NEXUS_URL = 'http://10.20.42.99:8081/repository/maven-releases/'
        DOCKER_IMAGE = 'myrepo/myapp'
        K8S_NAMESPACE = 'dev'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Pramodkumarsv/CI-CD.git'
            }
        }
        
        stage('Compile & Unit Test') {
            steps {
                sh '/usr/bin/mvn clean compile test'
            }
        }
        
        stage('Static Code Analysis - SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.host.url=$SONARQUBE_URL'
                }
            }
        }
        
        stage('Build & Upload Artifact to Nexus') {
            steps {
                sh 'mvn clean package'
                sh 'mvn deploy -DaltDeploymentRepository=nexus-releases::default::$NEXUS_URL'
            }
        }
        
        stage('Build & Scan Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
                sh 'trivy image --severity HIGH,CRITICAL $DOCKER_IMAGE:$BUILD_NUMBER'
            }
        }
        
        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                    sh 'docker push $DOCKER_IMAGE:$BUILD_NUMBER'
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                if [ -f k8s/deployment.yaml ]; then
                    kubectl apply -f k8s/deployment.yaml -n $K8S_NAMESPACE
                else
                    echo "Deployment file not found!"
                    exit 1
                fi
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                sh 'kubectl rollout status deployment myapp -n $K8S_NAMESPACE'
            }
        }
    }

    post {
        success {
            mail to: 'pramodkumarvagannanavar@gmail.com',
                 subject: "Deployment Successful - Build #${BUILD_NUMBER}",
                 body: "The application has been successfully deployed."
        }
        failure {
            mail to: 'pramodkumarvagannanavar@gmail.com',
                 subject: "Deployment Failed - Build #${BUILD_NUMBER}",
                 body: "The deployment has failed. Check Jenkins logs."
        }
    }
}
