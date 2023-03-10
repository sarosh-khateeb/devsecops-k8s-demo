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
              parallel(
                "Dependency Scan": {
                  sh "mvn dependency-check:check"      
                },
                "Trivy Scan": {
                  sh "bash trivy-docker-image-scan.sh"
                }//,
                //"OPA Conftest": {
                //  sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                //}
              )

            }
          }               
      stage('Docker build and push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: "https://index.docker.io/v1/"]){
              sh 'printenv'
              sh 'sudo docker build -t saroshkhateeb/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push saroshkhateeb/numeric-app:""$GIT_COMMIT""'
                }
              }    
          }

      stage('Vulnerability scan - kubernetes') {
            steps {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
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
      //stage('OWASP ZAP DAST') {
      //      steps {
      //        withKubeConfig([credentialsId: 'kubeconfig']){
      //           sh 'bash zap.sh'
      //          }
      //        }    
      //    }
      stage('Prompt to PROD?') {
            steps {
              timeout(time: 2, unit: 'DAYS'){
                 input 'Do you want to Approve the deployment to Production Envrinment/Namespace?'
                }
              }    
          }          
      stage('K8s CIS Benchmark') {
            steps {
              parallel(
                "Master": {
                  sh "bash cis-master.sh"      
                },
                "Etcd": {
                  sh "bash cis-etcd.sh"
                },
                "Kubelet": {
                  sh "bash cis-kubelet.sh"
                }
              )

            }
          }
          stage('K8s promotion/deploymen to PROD') {
           steps {
              parallel(
                "Deployment": {
                  withKubeConfig([credentialsId:'kubeconfig']){
                     sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml" 
                     sh "kubectl -n prod apply -f k8s_PROD_deployment_service.yaml"
                  }
                },
                "Rollout status": {
                  withKubeConfig([credentialsId: 'kubeconfig']){
                    sh "bash k8s_PROD_deployment_rollout_status.sh"  
                    }
                }
              )  
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

    } 
}
