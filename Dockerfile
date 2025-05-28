# Базовый образ Ruby
FROM ruby:3.2.2

# Установка зависимостей и Node.js с npm
RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -y curl gnupg postgresql-client imagemagick && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs


# Установка yarn (через npm)
RUN npm install -g yarn

# Установка рабочего каталога
WORKDIR /app

# Копируем Gemfile и устанавливаем зависимости
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Копируем всё приложение
COPY . .

# Разрешаем скрипту запускаться
RUN chmod +x entrypoint.sh

# Указываем точку входа
ENTRYPOINT ["./entrypoint.sh"]

# Порт
EXPOSE 3000

# Команда по умолчанию
CMD ["rails", "server", "-b", "0.0.0.0"]
