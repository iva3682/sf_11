pipeline {
    agent any

    environment {
        // Телеграм токен и чат айдишник
        TELEGRAM_BOT_TOKEN = '7799378463:AAEYSgulLDvl-0B912u3Pkmftas-wD-muec'
        TELEGRAM_CHAT_ID = '6236710120'
        
        // Имя Docker-образа
        DOCKER_IMAGE_NAME = 'nginx-image'
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
            }
        }
    
        stage('Build Docker Image') {
            steps {
                sh 'sudo docker build -t $DOCKER_IMAGE_NAME .'
            }
        }
    
        stage('Run Tests') {
            steps {
                script {
                    def containerId = sh(returnStdout: true, script: 'docker run --rm -d -p 9889:80 $DOCKER_IMAGE_NAME').trim()
                    
                    sleep(time: 5, unit: 'SECONDS')
                    
                    // Проверка HTTP статуса
                    def statusCode = sh(returnStdout: true, script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:9889/')
                    if (!statusCode.equals("200")) {
                        error("Ошибка! Статус ответа не равен 200")
                    }
                
                    // Проверка MD5 суммы
                    def originalMd5 = sh(returnStdout: true, script: 'md5sum index.html | cut -f1 -d\' \'')
                    def downloadedHtml = sh(returnStdout: true, script: 'curl -s http://localhost:9889/')
                    def downloadedMd5 = sh(returnStdout: true, script: "echo '$downloadedHtml' | md5sum | cut -f1 -d' '").trim()
                    
                    if (!originalMd5.trim().equals(downloadedMd5)) {
                        error("Файл изменён! Хеши различаются.")
                    }
                    
                    // Остановка и удаление контейнера
                    sh "docker stop $containerId"
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Чистка рабочего пространства
        }
        failure {
            script {
                // Формирование текста уведомления
                def message = "Ошибка в процессе CI: проверка HTML-файлов завершилась неудачей."
            
                // Отправка уведомления в Telegram
                sh """
                curl -X POST \
                  "https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage" \
                  -H 'Content-Type: application/json' \
                  -d '{"chat_id": "${env.TELEGRAM_CHAT_ID}", "text": "${message}"}'
                """
            }
        }
    }
}
