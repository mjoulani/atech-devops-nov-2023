properties([
        parameters([
                string(name: 'AWS_CRED', defaultValue: 'aws_cred', description: 'AWS Credentials ID'),
                string(name: 'S3_BUCKET', defaultValue: 'oferbakria', description: 'S3 Bucket Name'),
                string(name: 'S3_FILE', defaultValue: 'file_12.jpg', description: 'S3 File Name'),
                string(name: 'DEST', defaultValue: '${WORKSPACE}', description: 'Destination Folder'),
                string(name: 'REGION', defaultValue: 'ap-southeast-2', description: 'AWS Region'),
            
                // booleanParam(name: 'DEBUG', defaultValue: true, description: 'Enable Debugging'),

                // choice(name: 'CHOICE', choices: ['main', 'development', 'feature'], description: 'Choose one'),

                // [$class: 'CascadeChoiceParameter', choiceType: 'PT_CHECKBOX', filterLength: 1, filterable: false,
                //              name: 'MODULES', referencedParameters: 'AWS_CRED',
                //              script: [$class: 'GroovyScript', fallbackScript: [classpath: [], oldScript: '', sandbox: true, script: 'return [\'error\']'],
                //                       script: [classpath: [], oldScript: '', sandbox: true, script: 
                //                       '''
                //                       def list_modules = ['polybot', 'yolo5' , 'atechbot']
                //                       return list_modules
                //                       '''
                //                       ]]]   
         ])
])


pipeline {
    agent any

    stages {
        stage('Download from S3 Bucket') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
<<<<<<< HEAD
                    download_from_s3(params.AWS_CRED,params.S3_BUCKET,params.S3_FILE,"${WORKSPACE}")  
=======
                    download_from_s3("aws_cred","oferbakria","file_12.jpg","${WORKSPACE}")  
>>>>>>> main
                }
            }
        }
    }
}


//============================================================FUNC=====================================================

<<<<<<< HEAD
def download_from_s3(def cred,def bucket, def file, def dest,def region=params.REGION){
    withAWS(credentials: cred, region: region ) {
        println("Downloading file name ${file} from bucket ${bucket} to ${dest}")
        // sh "aws s3 cp s3://${bucket}/${file} ${dest}" 
        s3Download(file:"downloaded_${file}", bucket:bucket, path:file, force:true)         
=======
def download_from_s3(def cred,def bucket, def file, def dest,def region='ap-southeast-2'){
    withAWS(credentials: cred, region: region ) {
        println("Downloading file name ${file} from bucket ${bucket} to ${dest}")
        // sh "aws s3 cp s3://${bucket}/${file} ${dest}"   
        s3Download(file:"downloaded_${file}", bucket:bucket, path:file, force:true)      
>>>>>>> main
    }
}
    