properties([
        parameters([
                string(name: 'AWS_CRED', defaultValue: 'aws_cred', description: 'AWS Credentials ID'),
                string(name: 'S3_BUCKET', defaultValue: 'oferbakria', description: 'S3 Bucket Name'),
                string(name: 'S3_FILE', defaultValue: '/var/jenkins_home/workspace/upload_to_s3/ofer.jpg', description: 'S3 File Name'),
                string(name: 'TARG', defaultValue: 'upload_from_jenkins/', description: 'Target File'),
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
        stage('Upload to S3 Bucket') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    upload_to_s3(params.AWS_CRED,params.S3_BUCKET,params.S3_FILE,params.TARG)  
                }
            }
        }
    }
}


//============================================================FUNC=====================================================

def upload_to_s3(def cred,def bucket, def file, def target,def region=params.REGION){
    withAWS(credentials: cred, region: region ) {
        println("uploading file name ${file} from bucket ${bucket} to ${target}")
        // sh "aws s3 cp s3://${bucket}/${file} ${dest}" 
        // s3Upload(bucket: bucket, path:'aaa.jpg', includePathPattern:'**/*', workingDir:file, excludePathPattern:'**/*.png,**/*.jpg')        
        s3Upload(file:file, bucket:bucket, path:target)
    }
}
    
