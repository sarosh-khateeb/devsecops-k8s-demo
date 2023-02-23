pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
          }
      stage('Unit Test Artifact') {
            steps {
              sh "mvn test"
            }
          }
      stage('Docker build and push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: "https://index.docker.io/v1/"]){
              sh 'printenv'
              sh 'docker build -t saroshkhateeb/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push saroshkhateeb/numeric-app:""$GIT_COMMIT""'
                }
              }    
          }  
      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']){
                 sh "sed -i 's#replace#sarosh-khateeb/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                 sh "kubectl apply -f k8s_deployment_service.yaml"
                }
              }    
          }        
    } 
}
