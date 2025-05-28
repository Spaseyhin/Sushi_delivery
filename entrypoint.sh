#!/bin/bash
set -e

# Ждём, пока база будет готова
until pg_isready -h db -p 5432 -U postgres; do
  echo "Waiting for postgres..."
  sleep 1
done

# Подготавливаем БД
bundle exec rails db:prepare

# Выполняем сиды (создание админа и т.д.)
bundle exec rails db:seed

# Запуск переданной команды (из CMD в Dockerfile)
exec "$@"
