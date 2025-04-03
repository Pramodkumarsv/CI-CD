pipeline {
    agent any

    environment {
        SONARQUBE_URL = 'http://10.20.42.99:9000/'
        SONARQUBE_TOKEN = credentials('SONARQUBE_TOKEN')
        NEXUS_URL = 'http://10.20.42.99:8081/repository/maven-releases/'
        NEXUS_CREDENTIALS = credentials('NEXUS_CREDENTIALS')
        DOCKER_IMAGE = 'pramodkumar054/myapp'
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
                    sh 'mvn sonar:sonar -Dsonar.host.url=$SONARQUBE_URL -Dsonar.login=$SONARQUBE_TOKEN'
                }
            }
        }
        
        stage('Build & Upload Artifact to Nexus') {
            steps {
                sh '''
                    mvn deploy \
                        -DaltDeploymentRepository=nexus-releases::default::http://10.20.42.99:8081/repository/maven-releases/ \
                        -Dnexus.username=$NEXUS_CREDENTIALS_USR \
                        -Dnexus.password=$NEXUS_CREDENTIALS_PSW
                '''
            }
        }
        
        stage('Build & Scan Docker Image') {
            steps {
                sh 'sudo docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .'
                
                // Ensure Trivy DB is updated before scanning
                sh 'sudo docker run --rm aquasec/trivy:latest image --download-db-only'
                
                // Run vulnerability scan with updated DB
                sh '''
                sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                -v $HOME/.cache/trivy:/root/.cache/trivy \
                aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL \
                $DOCKER_IMAGE:$BUILD_NUMBER
                '''
            }
        }
    


        
        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'sudo docker login -u $DOCKER_USER -p $DOCKER_PASS'
                    sh 'sudo docker push $DOCKER_IMAGE:$BUILD_NUMBER'
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    if [ -f k8s/deployment.yaml ]; then
                        kubectl apply --validate=false -f k8s/deployment.yaml -n $K8S_NAMESPACE
                    else
                        echo "Deployment file not found!"
                        exit 1
                    fi
                    '''
                }
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
