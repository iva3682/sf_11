import requests

def send_telegram_message(chat_id, text):
    token = '7799378463:AAEYSgulLDvl-0B912u3Pkmftas-wD-muec'
    url = f'https://api.telegram.org/bot{token}/sendMessage'
    params = {'chat_id': chat_id, 'text': text}
    response = requests.get(url, params=params)
    return response.json()

# Используем этот скрипт в shell-команде:
message="Error in CI pipeline for Nginx deployment"
response=send_telegram_message('6236710120', message)