#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake db:migrate
# Принудительно прогоняем сиды
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rake db:seed
fi
