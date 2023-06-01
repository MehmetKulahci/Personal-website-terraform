pipeline {
    agent any
    environment {
        PATH=sh(script:"echo $PATH:/usr/local/bin", returnStdout:true).trim()
        
    }
    stages {
        

        stage('Create QA Automation Infrastructure') {
            steps {
                echo 'Creating QA Automation Infrastructure for Dev Environment'
                sh """
                  
                    terraform init
                    terraform apply -auto-approve -no-color
                """
                
            }
        }


        
}