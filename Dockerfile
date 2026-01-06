FROM python:3.9-alpine3.16

# Устанавливаем системные зависимости
RUN apk update && apk add --no-cache \
    postgresql-libs \
    gcc \
    musl-dev \
    postgresql-dev \
    python3-dev \
    libffi-dev \
    openssl-dev

# Копируем и устанавливаем зависимости
COPY requirements.txt /temp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /temp/requirements.txt

# Очистка для уменьшения размера образа
RUN apk del gcc musl-dev postgresql-dev python3-dev libffi-dev openssl-dev && \
    rm -rf /var/cache/apk/*

# Копируем приложение
COPY service /service
WORKDIR /service

# Создаем пользователя
RUN adduser -D -H service-user && \
    chown -R service-user:service-user /service

USER service-user

EXPOSE 8000

# Команда по умолчанию
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]