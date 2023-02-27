pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
          }

      stage('Unit Test - Junit and jacoco') {
            steps {
              sh "mvn test"
            }
          }
      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
          }
      stage('SAST Sonarqube'){
            steps {
              sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://localhost:9000 -Dsonar.login=sqp_39fc81638595107f4ebde91edcf65b8541dd594e"
            }
          }
      stage('Vulnerability Scan on Dependencies- b4 Docker') {
            steps {
              sh "mvn dependency-check:check"
            }
          }
      stage('Vulnerability Scan - Docker') {
            steps {
              parallel{
                "Dependency Scan": {
                  sh "mvn dependency-check:check"      
                },
                "Trivy Scan": {
                  sh "bash trivy-docker-image-scan.sh"
                }
              }

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
                 sh "sed -i 's#replace#saroshkhateeb/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                 sh "kubectl apply -f k8s_deployment_service.yaml"
                }
              }    
          }        
    }
    post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              }
              //successs{

              //}
              //failure{

              //}
    } 
}
