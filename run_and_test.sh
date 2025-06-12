#!/bin/bash

# Запускаем контейнер
CONTAINER_ID=$(docker run --rm -d -p 9889:80 nginx-image)
echo "Container started with ID: ${CONTAINER_ID}"

# Ждем некоторое время, пока контейнер запустится
sleep 5

# Тестируем статус ответа
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9889/)
if [[ "${STATUS_CODE}" != "200" ]]; then
    echo "Ошибка! Статус ответа не равен 200"
    # Отправляем уведомление (см. ниже)
else
    echo "HTTP-статус OK!"
fi

# Получаем исходное содержимое index.html
ORIGINAL_MD5=$(md5sum index.html | awk '{print $1}')

# Загружаем изменённое содержимое с сайта
DOWNLOADED_HTML=$(curl -s http://localhost:9889/)
DOWNLOADED_MD5=$(echo "$DOWNLOADED_HTML" | md5sum | awk '{print $1}')

# Сравниваем хеши
if [[ "${ORIGINAL_MD5}" != "${DOWNLOADED_MD5}" ]]; then
    echo "Файл изменён! Хеши различаются."
    # Отправляем уведомление (см. ниже)
else
    echo "Хеши совпадают."
fi

# Остановка и удаление контейнера
docker stop ${CONTAINER_ID}