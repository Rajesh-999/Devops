### Creation of EC2 instance based on region for different environments using    terraform by Jenkins CI/CD pipeline

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)

## Step 1: Installation of terraform and AWS credentials plugins in Jenkins

 

Configure terraform path details in Jenkins
You need to download terraform prior to configure details in Jenkins
     - Windows :-  Choco install terraform

 Jenkins --> Manage Jenkins -->Tools -->Terraform Installation

 
Now configure the AWS access keys, 
Select Kind as “AWS Credentials” 

 

## Step 2 : creation of main.tf and variable.tf files 

You can create those files in your local system and then push to remote (GITHUB) or you can create directly in remote.

- File : variable.tf 

here we want to create 2 variables in our project  1. Region 2 AMI

![image](https://github.com/user-attachments/assets/44e019c5-b723-4978-b054-87992287014c)

- File : main.tf

- ![image](https://github.com/user-attachments/assets/880b2473-d9f3-45a7-927d-4eed49f54427)


 
This block defines the provider details and region shall be fetched from variable.tf file with the name of variable as “region”

![image](https://github.com/user-attachments/assets/3e6cc8a8-0997-487a-a5d4-c20a9ec76a57)


 

This block defines the location where the “state” file shall be stored.

![image](https://github.com/user-attachments/assets/2a8006d5-ecd1-44b0-a9b1-6de53ff2568f)


 

This block defines the resource we are creating as “aws_instance” and the name as “web2”.AMI ID is variable so it is fetching from the variable.tf file.

![image](https://github.com/user-attachments/assets/5bd8337f-b2ea-47e3-9faa-445fb65f155c)


 

Here I am commenting the “VPC” , as VPC and security groups are region specific I am going with default VPC and security groups , if we want separate we can create.

![image](https://github.com/user-attachments/assets/d712a695-b969-44f3-a421-4d9ce2b17b4c)


  

Launching my EC2 instance with static HTML page. As we are using default VPC and security group you have to define inbound rules otherwise page will not be accessed.

![image](https://github.com/user-attachments/assets/28aa01be-e36d-4b0e-b30a-5e6347cd77fc)


 

Here we can give the name of the instance as “Hello2”

## Step 3: Writing the CI/CD pipeline code

parameters {
        
        choice(name: 'instance', choices: ['dev', 'test', 'prod'], description: 'Select your region')
        
    }

When there is need to user’s input then we can use parameters block.Jenkins job will ask for user input

environment {
        
        EC2_REGIONS = ''
        AMI_ID = ''
    }

We have 2 variable to be passed with terraform command so I am using 2 environment variable with null value.

```bash
stages {
        stage('checkout') {
            steps {
                git 'https://github.com/Rajesh-999/Devops.git'
            }
        }
```

Cloning the source code from github.

```bash
stage('set region values'){
            steps{
                script{
                    // Define default AWS region and AMI ID's for each environment
                  def AWS_REGIONS = [dev: 'us-west-1', test: 'us-east-1', prod: 'eu-central-1']
                  def AWS_AMI_IDS = [dev: 'ami-04fdea8e25817cd69', test: 'ami- 066784287e358dad1', prod: 'ami-0de02246788e4a354']
                  
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
```

I have taken 2 local variables(AWS_REGIONS && AWS_AMI_IDS) with dictionary type and assigned key -value pairs. And extracting the value based on choice selected by the user

    def reg = AWS_REGIONS[params.instance]
    def IDS = AWS_AMI_IDS[params.instance]

and assigning this value to global variables

EC2_REGIONS = reg ;
AMI_ID= IDS

Now, we can use terraform commands like init ,plan, and apply
```bash
stage('Terraform init'){
            steps{
                withCredentials([aws(credentialsId: "AWS_Access_Key")]){
                  script{
                     bat 'terraform init'
                  }
                }
            }
        }
```
Jenkins needs AWS credentials to access, so I have given the credentials ID which was created in initial steps.

```bash
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
```      
