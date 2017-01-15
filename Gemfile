source "https://rubygems.org"

gem "sinatra",          require: "sinatra/base"
gem "sinatra-param",    require: "sinatra/param"

gem "rack-contrib",     require: "rack/contrib"
gem "rack-protection",  require: "rack/protection"
gem "redis-rack",       require: "rack/session/redis"

gem "sqlite3"
gem "sinatra-activerecord", require: "sinatra/activerecord"

gem "rake"
gem "seed-fu"
gem "dotenv"

gem "thin", require: false

group :development do
  gem "pry"
  gem "shotgun",            require: false
  gem "better_errors"
  gem "binding_of_caller",  require: false
end

group :test do
  gem "factory_girl"
  gem "rspec"
  gem "rack-test"
  gem "minitest"
end
