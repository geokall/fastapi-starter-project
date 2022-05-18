pipeline {

    agent any


    stages {

        stage('clone') {

            steps {

               sh '''
                    cp app/.env.example app/.env
                    docker-compose down --volumes
                    docker-compose up -d --build
                    docker-compose exec fastapi pytest
               '''

            }

        }

        stage('test') {

            steps {

                sh '''

                    echo 'Test'

                '''

            }

        }

    }


}