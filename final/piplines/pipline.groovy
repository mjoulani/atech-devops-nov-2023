import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.transform.Field

@Field JOB = [:]

JOB.trigg_by = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause').userName

PROP = [:]

PROP['git_cred'] = 'github'
PROP['branch'] = 'oferbakria'
PROP['proj_url'] = 'https://github.com/AlexeyMihaylovDev/atech-devops-nov-2023'

PROP['dockerhub_cred'] = 'dockerhub_cred' // Jenkins credential ID for DockerHub
PROP['docker_image1'] = 'oferbakria/poly'
PROP['docker_image2'] = 'oferbakria/yolo'
PROP['docker_tag'] = '1.1'
PROP['aws_cli_cred'] = 'aws_cred'

// PROP['docker_file_path'] = 'flask/Dockerfile'
// PROP['ecr_registry'] = '933060838752.dkr.ecr.eu-west-1.amazonaws.com/ofer'
// PROP['aws_region'] = 'eu-west-1'
// PROP['image_name'] = 'ofer-flask-image'

// PROP['email_recepients'] = "alexeymihaylovdev@gmail.com"

pipeline {

    agent { label 'jenkins_ec2' } // Use the label of your EC2 agent

    // triggers {
    //     GenericTrigger(
    //             genericVariables: [
    //                     [key: 'refsb', value: '$.ref'],
    //                     [key: 'pusher', value: '$.pusher.name'],
    //                     [key: 'change_files', value: '$.commits[0].modified[0]'],
    //                     // [key: 'type', value: '$.changes[0].type'],
    //             ],
    //             token: "123456",
    //             tokenCredentialId: '',
    //             printContributedVariables: true,
    //             printPostContent: false,
    //             silentResponse: false,
    //             regexpFilterText: '$refsb $change_files',
    //             regexpFilterExpression: '^(refs/heads/main)'        
    //     )
    // }


    stages {

    // stage('Hello'){
    //     steps {
    //         script {
    //             println("=====================================${STAGE_NAME}=====================================")
    //             println("Hello ${PROP.trigg_by}")
    //         }
    //     }
    // }








    stage('Git clone') {
        steps {
            script {
                println("=====================================${STAGE_NAME}=====================================")
                println("Cloning from branch ${PROP.branch} and using credentials ${PROP.git_cred}")

                // Enable sparse checkout
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: "*/${PROP.branch}"]],
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [
                        [$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [[path: 'final']]]
                    ], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [[
                        credentialsId: PROP.git_cred, 
                        url: PROP.proj_url
                    ]]
                ])
            }
        }
        }



    stage('Create Docker Image') {
        steps {
             script {
             println("=====================================${STAGE_NAME}=====================================")
                sh "docker build -t ${PROP.docker_image1}:${PROP.docker_tag} ./final/aws_project/polybot"
                sh "docker build -t ${PROP.docker_image2}:${PROP.docker_tag} ./final/aws_project/yolo5"
             }
        }
    }

    stage('Push Docker Images') {
        steps {
            script {
                println("=====================================${STAGE_NAME}=====================================")
                withCredentials([usernamePassword(credentialsId: PROP.dockerhub_cred, passwordVariable: 'DOCKERHUB_PASS', usernameVariable: 'DOCKERHUB_USER')]) {

                    sh """
                        echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                        docker push ${PROP.docker_image1}:${PROP.docker_tag}
                        docker push ${PROP.docker_image2}:${PROP.docker_tag}

                        docker rmi -f ${PROP.docker_image1}:${PROP.docker_tag}
                        docker rmi -f ${PROP.docker_image2}:${PROP.docker_tag}
                    """
                }
            }
        }
    }



    stage('Read helm chart values'){
        steps{
            script{  
                    dir("${WORKSPACE}/final")  {
                    sh 'ls -l'    
                def chartValues = readFile (file: 'values.yaml')  
                JOB.buildChartValues = chartValues
                    }
                println(JOB.buildChartValues)
                            
            }
            
        }
    }



    stage('Input params '){
        when{
            expression { !JOB.trigg_by.isEmpty()}
        }
        steps{
            script{
                def userInput = input (id: 'userInput', message: 'Please provide the following parameters', parameters: [
                    [$class: 'WHideParameterDefinition', defaultValue: JOB.buildChartValues, description: '', name: 'chartValues'],
                    choice(name: 'CHOICE_HELM', choices: ['install','upgrade','uninstall'], description: 'Choose one'),
                    [$class: 'DynamicReferenceParameter', choiceType: 'ET_FORMATTED_HTML', description: "",
                            name: 'ChartValues', omitValueField: true, referencedParameters: 'chartValues',
                            script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: true,
                                                                            script: 'return [\'error\']'], script: [classpath: [], sandbox: true, script: '''
                            def jsonValue = "${chartValues}".replaceAll('"', '\\\\"') 
                            return "<textarea name=\\"value\\" rows='27' cols='100'>${jsonValue}</textarea>"
                        ''']]],

                ])
                JOB.params = userInput['ChartValues']
                sh 'rm -f values.yaml' //delete old values.yaml

            }
        }
    }



        stage('Helm update values by user input'){
            when{
                expression { !JOB.trigg_by.isEmpty()}
            }
            steps{
                script{
                     dir("${WORKSPACE}/final")  {
                        writeFile file: 'values.yaml', text: JOB.params
                    }
                }
            }
        }


        stage('Login to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: PROP['aws_cli_cred']]]) {
                    script {
                        sh 'aws eks --region us-east-1 update-kubeconfig --name k8s-main'
                    }
                }
            }
        }



        stage('Helm install'){
            steps{
                script{
                     dir("${WORKSPACE}/final")  {
                        sh 'helm install ofertest -f values.yaml -n oferbakria .'
                    }
                }
            }
        }





    }

    
}
// install helm and kubectl add correct aws cred