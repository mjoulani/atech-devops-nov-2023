properties([
        parameters([
                string(name: 'AWS_CRED', defaultValue: 'aws_cred', description: 'AWS Credentials ID'),
                string(name: 'S3_BUCKET', defaultValue: 'alexey--demo', description: 'S3 Bucket Name'),
                string(name: 'S3_FILE', defaultValue: 'demofile', description: 'S3 File Name'),
                string(name: 'DEST', defaultValue: '${WORKSPACE}', description: 'Destination Folder'),
                string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS Region'),
                booleanParam(name: 'DEBUG', defaultValue: false, description: 'Enable Debugging'),
                choice(name: 'CHOICE', choices: ['one', 'two', 'three'], description: 'Choose one'),
                [$class: 'CascadeChoiceParameter', choiceType: 'PT_CHECKBOX', filterLength: 1, filterable: false,
                             name: 'Modules', referencedParameters: '',
                             script: [$class: 'GroovyScript', fallbackScript: [classpath: [], oldScript: '', sandbox: true, script: 'return [\'error\']'],
                                      script: [classpath: [], oldScript: '', sandbox: true, script: 
                                      '''
                                      def list_modules = ['polybot', 'yolo5' , 'atechbot']
                                      return list_modules
                                      '''
                                      ]]]
         ])
])

pipeline {
    agent any

    stages {
        stage('Download from S3 Bucket') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    download_from_s3("${params.AWS_CRED}","${params.S3_BUCKET}","${params.S3_FILE}","${params.DEST}","${params.REGION}")  
                }
            }
        }
    }
}


//============================================================FUNC=====================================================

def download_from_s3(def cred,def bucket, def file, def dest,def region='us-east-1'){
    withAWS(credentials: cred, region: region ) {
        println("Downloading file name ${file} from bucket ${bucket} to ${dest}")
        sh "aws s3 cp s3://${bucket}/${file} ${dest}"         
    }
}
    
