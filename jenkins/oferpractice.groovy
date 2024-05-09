PROP = [:]

PROP['git_cred'] = 'github'
PROP['branch'] = 'main'
PROP['docker_tag'] = '1.0'
PROP['docker_file_path'] = 'flask/Dockerfile'
PROP['ecr_registry'] = '933060838752.dkr.ecr.eu-west-1.amazonaws.com'
PROP['aws_region'] = 'eu-west-1'
PROP['aws_cli_cred'] = 'aws_cred'
PROP['image_name'] = 'ofer-flask-image'
// PROP['email_recepients'] = "alexeymihaylovdev@gmail.com"

pipeline {
    agent { label 'jenkins_ec2' } // Use the label of your EC2 agent
    stages {
        stage('Git clone') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    println("Cloning from branch ${PROP.branch} and using credentials ${PROP.git_cred}")
                    git branch: PROP.branch, credentialsId: PROP.git_cred, url: 'https://github.com/ofirbakria/practice'
                }
            }
        }


        // stage('Create Docker Image') {
        //     steps {
        //          script {
        //          println("=====================================${STAGE_NAME}=====================================")
        //           sh "docker build -t ${PROP.ecr_registry}/${PROP.image_name}:${PROP.docker_tag} -f  ${PROP.docker_file_path} ."
        //          }
        //     }
        // }
        
        // stage('Upload to ECR AWS') {
        //     steps {
        //         script {
        //         println("=====================================${STAGE_NAME}=====================================")
        //             withAWS(credentials: PROP.aws_cli_cred , region: PROP.aws_region ) { 
        //             def login = ecrLogin()
        //             sh "${login}"
        //             sh "docker push ${PROP.ecr_registry}/${PROP.image_name}:${PROP.docker_tag}"
        //             }
        //         }
        //     }
        // }

        stage('Run Terraform to create a new ec2 instance') {
            steps {
                script {
                println("=====================================${STAGE_NAME}=====================================")
                sh "sudo apt get update"

                sh "cd ./terraform && sudo chmod +x user_data.sh"
                sh "cd ./terraform && terraform init && terraform apply -auto-approve"
                sh "cd ./terraform && terraform output -json > file.json"
                sh "sudo apt install jq"//cat file.json | jq -r '.["ec2-public_ip"].value'

                }
            }
        }
  }
}
