# Базовый образ: Python 3.9 на Alpine Linux (легковесный дистрибутив)
FROM python:3.9-alpine3.16

# Установка системных зависимостей для сборки Python-пакетов
RUN apk update && apk add --no-cache \
    postgresql-libs \           # Клиентские библиотеки PostgreSQL
    gcc \                       # Компилятор C
    musl-dev \                  # Стандартная библиотека C
    postgresql-dev \            # Заголовки для PostgreSQL (нужны для psycopg2)
    python3-dev \               # Заголовки Python для компиляции
    libffi-dev \                # Для криптографических пакетов
    openssl-dev                 # Для SSL/TLS

# Копируем файл зависимостей и устанавливаем Python-пакеты
COPY requirements.txt /temp/requirements.txt
RUN pip install --upgrade pip && \                        # Обновляем pip до последней версии
    pip install --no-cache-dir -r /temp/requirements.txt  # Устанавливаем зависимости без кэша

# Удаляем ненужные зависимости для уменьшения размера образа
RUN apk del gcc musl-dev postgresql-dev python3-dev libffi-dev openssl-dev && \
    rm -rf /var/cache/apk/*                     # Очищаем кэш пакетов

# Копируем код приложения в контейнер
COPY service /service
WORKDIR /service                                # Устанавливаем рабочую директорию

# Создаем непривилегированного пользователя для безопасности
RUN adduser -D -H service-user && \             # Создаем пользователя без пароля
    chown -R service-user:service-user /service # Меняем владельца файлов

USER service-user                               # Переключаемся на созданного пользователя

EXPOSE 8000                                     # Объявляем порт для доступа к приложению

# Команда по умолчанию при запуске контейнера
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]