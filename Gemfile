source "https://rubygems.org"

gem "sinatra",          require: "sinatra/base"

gem "rack-contrib",     require: "rack/contrib"
gem "rack-protection",  require: "rack/protection"
gem "redis-rack",       require: "rack/session/redis"
gem "rack-ltsv_logger"

gem "mysql2"
gem "sinatra-activerecord", require: "sinatra/activerecord"

gem "oj"
gem "oj_mimic_json"

gem "rake"
gem "seed-fu"
gem "dotenv"

gem "puma", require: false
gem "tzinfo-data"

group :development do
  gem "pry"
  gem "pry-byebug"
  gem "rack-lineprof"
end

group :test do
  gem "factory_girl"
  gem "rspec"
  gem "rack-test"
end
