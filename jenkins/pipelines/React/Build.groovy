//http://localhost:8080/generic-webhook-trigger/invoke?token=abc123


PROP = [:]

PROP['git_cred'] = 'github_ssh_key'
PROP['branch'] = 'main'
PROP['docker_tag'] = 'latest'
PROP['docker_file_path'] = 'Dockerfile.prod'
PROP['ecr_registry'] = '933060838752.dkr.ecr.eu-central-1.amazonaws.com'
PROP['aws_region'] = 'eu-central-1'
PROP['aws_cli_cred'] = 'aws_cli_cred'
PROP['image_name'] = 'hello-world-app'


pipeline {
    agent {
        docker {
            label 'linux'
            image 'public.ecr.aws/q1f8b0h6/jenkins_agent:latest'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
        triggers {
        GenericTrigger(
                genericVariables: [
                        [key: 'refsb', value: '$.ref'],
                        [key: 'pusher', value: '$.pusher.name'],
                        [key: 'change_files', value: '$.commits[0].modified[0]']
                ],
                token: "react_app",
                tokenCredentialId: '',
                printContributedVariables: true,
                printPostContent: false,
                silentResponse: false,
                regexpFilterText: '$refsb',
                regexpFilterExpression: '^(refs/heads/main|refs/remotes/origin/main)'
                
        )
    }
    stages {
        stage('Git clone') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    println("Cloning from branch ${PROP.branch} and using credentials ${PROP.git_cred}")
                    git branch: PROP.branch, credentialsId: PROP.git_cred, url: 'git@github.com:AlexeyMihaylovDev/hello-world-app.git'
                }
            }
        }
        stage('Create Docker Image') {
            steps {
                 script {
                 println("=====================================${STAGE_NAME}=====================================")
                  sh "docker build -t ${PROP.ecr_registry}/${PROP.image_name}:${PROP.docker_tag} -f  ${PROP.docker_file_path} ."
                 }

            }
        }
        stage('Upload to ECR AWS') {
            steps {
                script {
                println("=====================================${STAGE_NAME}=====================================")
                    withAWS(credentials: 'aws_cli_cred', region: 'eu-central-1') { 
                    def login = ecrLogin()
                    sh "${login}"
                    sh "docker push ${PROP.ecr_registry}/${PROP.image_name}:${PROP.docker_tag}"
                    }
                }
            }
        }
        // if you want to trigger deploy job
        stage('Trigger Deploy Job') {
            steps {
                build job: 'React/Deploy', parameters: [string(name: 'IMAGE_NAME', value: "${PROP.image_name}")]
            }
        }
    }
    
    post {
        always {
            echo 'This will always run'
        }
        
    }
}
