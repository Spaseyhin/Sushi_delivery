#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake db:migrate
bundle exec rake db:seed
# bin/rails assets:precompile