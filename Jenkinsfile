pipeline {
    agent any

  stages {
   
        stage('Fetch code') {
            steps {
               git branch: 'main', url: 'https://github.com/luciancibu/AWS-resume.git'
               sh 'echo "Code fetched successfully!"'
            }

        }

  }
}