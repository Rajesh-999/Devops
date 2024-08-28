pipeline {
    agent any
    
    parameters {
        
        choice(name: 'instance', choices: ['dev', 'test', 'prod'], description: 'Select your region')
        
    }
    
    environment {
        
        EC2_REGIONS = ''
        AMI_ID = ''
    }
    

    stages {
        stage('checkout') {
            steps {
                git 'https://github.com/Rajesh-999/Devops.git'
            }
        }
        stage('set region values'){
            steps{
                script{
                    // Define default AWS region and AMI ID's for each environment
                  def AWS_REGIONS = [dev: 'us-west-1', test: 'us-east-1', prod: 'eu-central-1']
                  def AWS_AMI_IDS = [dev: 'ami-04fdea8e25817cd69', test: 'ami-066784287e358dad1', prod: 'ami-0de02246788e4a354']
                  
                  //echo "${params.instance}"
                    
                  def reg = AWS_REGIONS[params.instance]
                  def IDS = AWS_AMI_IDS[params.instance]
                  
                  //echo "${reg}"
                  EC2_REGIONS = reg
                  AMI_ID= IDS
                  echo "${AMI_ID}"
                  echo "EC2 instance will be created in  ${EC2_REGIONS} and ${AMI_ID}"
                }
            }
        }
        stage('Terraform init'){
            steps{
                withCredentials([aws(credentialsId: "AWS_Access_Key")]){
                  script{
                     bat 'terraform init'
                  }
                }
            }
        }
        stage('terraform plan'){
            steps{
                withCredentials([aws(credentialsId: "AWS_Access_Key")]){
                    script{
                       // bat "echo ${EC2_REGIONS}"
                        bat "terraform plan --var=region=${EC2_REGIONS} --var=ami_ids=${AMI_ID}"
                    }
                }
            }
        }
        stage('Terraform Apply'){
            steps{
                withCredentials([aws(credentialsId: "AWS_Access_Key")]){
                        script{
                        bat "terraform apply --var=region=${EC2_REGIONS} --var=ami_ids=${AMI_ID} -auto-approve"
                        }
                }
            }
        }
    }
}
