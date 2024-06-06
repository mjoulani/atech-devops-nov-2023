import groovy.json.JsonBuilder
import groovy.json.JsonSlurper
import groovy.json.JsonSlurperClassic
import groovy.transform.Field

@Field JOB = [:]

pipeline {

    agent { label params.AGENT}



    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    stages{
        stage('Git clone'){
            steps{
                git branch: 'main', url: 'https://github.com/AlexeyMihaylovDev/atech-devops-nov-2023.git'
            }
        }
        stage('Read helm chart values'){
            steps{
                script{

                    dir('k8s\helm\react_site'){
                    def chartValues = readYaml file: 'values.yaml'    
                    JOB.buildChartValues = chartValues
                    }               
                }
                
            }
         }
        }
        stage('Input params '){
            steps{
                script{
                    def userInput = input (id: 'userInput', message: 'Please provide the following parameters', parameters: [
                        [$class: 'WHideParameterDefinition', defaultValue: JOB.buildChartValues, description: '', name: 'chartValues'],
                        [$class: 'DynamicReferenceParameter', choiceType: 'ET_FORMATTED_HTML', description: "",
                             name: 'ChartValues', omitValueField: true, referencedParameters: 'chartValues',
                             script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: true,
                                                                               script: 'return [\'error\']'], script: [classpath: [], sandbox: true, script: '''
                                def jsonValue = "${chartValues}".replaceAll('"', '\\\\"') 
                                return "<textarea name=\\"value\\" rows='27' cols='100'>${jsonValue}</textarea>"
                            ''']]],                            
                    ])
                    JOB.params = readYaml text: userInput['ChartValues']
                }
            }
        }
        stage('Helm update values by user input'){
            steps{
                script{
                    dir('k8s\helm\react_site'){
                        sh 'rm -f values.yaml' //delete old values.yaml
                        def chartValues = JOB.buildChartValues
                        def params = JOB.params
                        def updatedChartValues = chartValues + params
                        writeFile file: 'values.yaml', text: JOB.params.toYaml()
                    }
                }
            }
        }
        stage('Helm install'){
            steps{
                script{
                    dir('k8s\helm\react_site'){
                        sh 'helm install react-site . -f values.yaml'
                    }
                }
            }
        }

    }