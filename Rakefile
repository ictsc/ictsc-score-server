require "bundler"

Bundler.require
Bundler.require(ENV["RACK_ENV"]) if ENV["RACK_ENV"]

require "sinatra/activerecord/rake"

require "rspec/core/rake_task" if ENV["RACK_ENV"] == "test"

namespace :db do
  desc <<-EOS
    Loads seed data for the current environment. It will look for
    ruby seed files in (settings.root)/db/fixtures/ and
    (settings.root)/db/fixtures/(settings.environment)/.

    By default it will load any ruby files found. You can filter the files
    loaded by passing in the FILTER environment variable with a comma-delimited
    list of patterns to include. Any files not matching the pattern will
    not be loaded.

    You can also change the directory where seed files are looked for
    with the FIXTURE_PATH environment variable.

    Examples:
      # default, to load all seed files for the current environment
      rake db:seed_fu

      # to load seed files matching orders or customers
      rake db:seed_fu FILTER=orders,customers

      # to load files from settings.root/features/fixtures
      rake db:seed_fu FIXTURE_PATH=features/fixtures
  EOS
  task :seed_fu => :environment do

    if ENV["FILTER"]
      filter = /#{ENV["FILTER"].gsub(/,/, "|")}/
    end

    if ENV["FIXTURE_PATH"]
      fixture_paths = [ENV["FIXTURE_PATH"], ENV["FIXTURE_PATH"] + "/" + ENV["RACK_ENV"]]
    end

    SeedFu.seed(fixture_paths, filter)
  end

  task :re_seed_fu => :environment do
    # TODO: 2回目移行のseed_fuが失敗する応急処置
    Rake::Task['db:environment:set'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:setup'].invoke
    Rake::Task['db:seed_fu'].invoke
  end

  task :load_config do
    require_relative "app"
  end
end

task :pry do
  require 'pry'
  require_relative 'pry_r'

  Pry::CLI.start(Pry::CLI.parse_options)
end

task :create_admin do
  require 'io/console'
  require_relative 'pry_r'

  def hash_password(key, salt = "")
    return nil unless key.is_a? String

    crypt_binname = case RUBY_PLATFORM
      when /darwin/;  "crypt_darwin_amd64"
      when /freebsd/; "crypt_freebsd_amd64"
      when /linux/;   "crypt_linux_amd64"
    end

    path = File.join('./ext', crypt_binname)
    hash, status = Open3.capture2(path, key, salt)
    if status.exitstatus.zero?
      hash.strip
    else
      nil
    end
  end

  if Member.find_by(role_id: ROLE_ID[:admin])
    puts 'admin user already exists'
    next
  end

  # Roleの登録に必要
  puts 'rake db:setupした?'
  print 'Password: '
  password = STDIN.noecho(&:gets).chomp
  p result = Member.create(name: 'admin', login: 'admin', hashed_password: hash_password(password), role: Role.find_by(id: ROLE_ID[:admin]))
end

Rake::Task["db:seed_fu"].enhance(["db:load_config"])

SeedFu.fixture_paths = [
  File.dirname(__FILE__) + "/db/fixtures",
  File.dirname(__FILE__) + "/db/fixtures/#{ENV["RACK_ENV"]}"
]

RSpec::Core::RakeTask.new("spec") if defined? RSpec::Core::RakeTask
