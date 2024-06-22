PROP = [:]

PROP['git_cred'] = 'github'
PROP['branch'] = 'oferbakria'
PROP['docker_tag'] = 'latest'
PROP['proj_url'] = 'https://github.com/ofirbakria/jenkins_project'

// PROP['docker_file_path'] = 'flask/Dockerfile'
// PROP['ecr_registry'] = '933060838752.dkr.ecr.eu-west-1.amazonaws.com/ofer'
// PROP['aws_region'] = 'eu-west-1'
// PROP['aws_cli_cred'] = 'aws_cred'
// PROP['image_name'] = 'ofer-flask-image'

// PROP['email_recepients'] = "alexeymihaylovdev@gmail.com"

pipeline {
    agent { label 'jenkins_ec2' } // Use the label of your EC2 agent
    stages {
        stage('Git clone') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    println("Cloning from branch ${PROP.branch} and using credentials ${PROP.git_cred}")
                    git branch: PROP.branch, credentialsId: PROP.git_cred, url: PROP.proj_url
                }
            }
        }


        // stage('Create Docker Image') {
        //     steps {
        //          script {
        //          println("=====================================${STAGE_NAME}=====================================")
        //           sh "docker build -t polybot:${PROP.docker_tag} ./my_proj/aws_project/polybot"
        //           sh "docker build -t metricstreamer:${PROP.docker_tag} ./my_proj/aws_project/metricStreamer"
        //          }
        //     }
        // }
        
   
  }
}
// create hosts.ini file and add the public_url into the hosts file