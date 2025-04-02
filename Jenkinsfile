pipeline {
    agent any
    environment {
        SONARQUBE_URL = 'http://10.20.42.99:9000/'
        SONARQUBE_TOKEN = credentials('sqa_9db12d7a00d6da5a9d94f91c0993e9aa246ac14d')
        NEXUS_URL = 'http://10.20.42.99:8081/repository/maven-releases/'
        DOCKER_IMAGE = 'myrepo/myapp'
        DOCKER_USERNAME = credentials('pramodkumar054')
        DOCKER_PASSWORD = credentials('PRamod@123')
        K8S_NAMESPACE = 'dev'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Pramodkumarsv/CI-CD.git'
            }
        }
        
        stage('Compile & Unit Test') {
            steps {
                sh 'mvn clean compile test'
            }
        }
        
        stage('Static Code Analysis - SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.host.url=$SONARQUBE_URL -Dsonar.login=$SONARQUBE_TOKEN'
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
                sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                sh 'docker push $DOCKER_IMAGE:$BUILD_NUMBER'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml -n $K8S_NAMESPACE'
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
