pipeline{
    agent any
        tools{
            maven "maven3.8.6"
        }
    stages{
        stage('GitClone'){
            steps{
                sh "echo Git Clone"
                git credentialsId: 'GitCred', url: 'https://github.com/sola-adebayo/Project.git'
            }
        }
        stage('Maven clean Build'){
            steps{
                sh "echo Start of Build"
                sh "mvn clean package"
            }
        }
        stage('CodeQuality'){
            steps{
                sh "echo start sonarQube Test"
                sh "mvn sonar:sonar"
            }
        }
        stage('Docker Build Image'){
            steps{
                sh "echo Start Docker build"
                sh "docker build -t adebayosola/project ."
            }
        }
        stage('Docker push'){
            steps{
                withCredentials([string(credentialsId: 'DOCKER_HUB_CRED', variable: 'DOCKER_HUB_CRED')]) {
                  sh '''  
                         docker login -u adebayosola -p ${DOCKER_HUB_CRED}
                         docker push adebayosola/project
                     '''     
                }
            }
        }
        stage('Docker Kubernetes Deployment'){
            steps{
                script{
                    kubernetesDeploy (configs: 'project.yml' , kubeconfigId: 'kube_config') 
                }
            }   
        }    
    }
}
