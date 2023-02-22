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
      stage('Dockerize image') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]){}
              sh 'printenv'
              sh 'docker build -t saroshkhateeb/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push saroshkhateeb/numeric-app:""$GIT_COMMIT""'
            
          }    
    } 
}   
