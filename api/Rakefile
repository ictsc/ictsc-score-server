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

Rake::Task["db:seed_fu"].enhance(["db:load_config"])

SeedFu.fixture_paths = [
  File.dirname(__FILE__) + "/db/fixtures",
  File.dirname(__FILE__) + "/db/fixtures/#{ENV["RACK_ENV"]}"
]

RSpec::Core::RakeTask.new("spec") if defined? RSpec::Core::RakeTask
