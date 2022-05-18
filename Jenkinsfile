pipeline {
    agent any
    environment {
            DOCKER_TOKEN = credentials('docker-push-secret-1')
            DOCKER_USER = 'geokall'
            DOCKER_SERVER = 'ghcr.io'
            DOCKER_PREFIX = 'ghcr.io/geokall/pms8-fastapi'
        }
        


    stages {
        stage('test') {
            steps {
                sh '''
                    cp app/.env.example app/.env
                    docker-compose kill -s SIGINT
                    docker-compose down --volumes
                    docker-compose up -d --build
                    while ! docker-compose exec fastapi wget -S --spider http://localhost:8000/docs ; do sleep 1; done
                    docker-compose exec fastapi pytest
                    docker-compose down --volumes
                '''
            }
        }
         stage('docker build and push') {
           

            steps {
                sh '''
                    HEAD_COMMIT=$(git rev-parse --short HEAD)
                    TAG=$HEAD_COMMIT-$BUILD_ID
                    docker build --rm -t $DOCKER_PREFIX:$TAG -t $DOCKER_PREFIX:latest -f fastapi.Dockerfile .  
                '''

                
                sh '''
                    echo $DOCKER_TOKEN | docker login $DOCKER_SERVER -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_PREFIX --all-tags
                '''
            }
         }

            stage('deploy to k8s') {
            steps {
                sh '''
                    HEAD_COMMIT=$(git rev-parse --short HEAD)
                    TAG=$HEAD_COMMIT-$BUILD_ID
                    kubectl config use-context microk8s
                    kubectl set image deployment/fastapi-deployment fastapi=$DOCKER_PREFIX:$TAG
                    RUNNING_TAG=$(kubectl get pods  -o=jsonpath="{.items[*].spec.containers[*].image}" -l component=fastapi | grep $TAG)
                    FOUND=$(echo $RUNNING_TAG | wc -l)
                    timeout --preserve-status 3m bash -c  -- "while [ $FOUND -eq  0 ] ; do echo \"waiting\"; sleep 1; done"
                '''
            }
        }
        
    }

}