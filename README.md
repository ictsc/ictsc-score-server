ICTSC スコアサーバー
---

[![CircleCI](https://circleci.com/gh/ictsc/ictsc-score-server.svg?style=svg)](https://circleci.com/gh/ictsc/ictsc-score-server)

# About

The contest site for [ICTSC](http://icttoracon.net/) (ICT Trouble Shooting Contest).

It's called also *score server*.  The main feature of this is to propose problem and marking.

This provides whole game operations during contest:

- Proposing a problems (participant to solve in contest)
- Creating and discussing issues
- Submitting and marking answers
  - with a scoreboard
- Announcing notices

## Architecture, using frameworks

- API
  - Written in Ruby
  - API framework: [Sinatra](https://github.com/sinatra/sinatra)
    - Provides JSON RESTful API (but session is stateful...)
  - ORM: [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord)
  - Provides role models
  - To embed relational entities, `with` parameter is provided many endpoints
- Front-end
  - Using [Vue.js](https://github.com/vuejs/vue) with vue-router, Vuex

## Requirements

### Production

1. Ruby 2.5.0 or later
  - `Bundler` gem (To install: `gem install bundler`)
2. MySQL compatible DB

### Development (using Docker)

1. Docker 17.05-ce or later
2. docker-compose

## How to use

### Production

- Requires MySQL compatible DB
1. Use docker-compose (Refer development steps)
2. On-premise (without Docker):

- API

```sh
$ git clone https://github.com/ictsc/ictsc-score-server.git
$ cd ictsc-score-server
$ cp .env{.sample,}
$ # Edit .env
$ bundle install --path vendor/bundle
$ bundle exec rackup
```

- UI

```sh
$ # Clone repository same as API
$ cd ui
$ npm install
$ npm run build # Built static files in `dist` direcotry
```

Example web server settings are located `ui/h2o.conf`

### Development

```sh
$ git clone https://github.com/ictsc/ictsc-score-server.git
$ cd ictsc-score-server
$ cp .env{.sample,}
$ # Edit .env
$ docker-compose build # or pull
$ docker-compose run --rm api rake db:setup db:seed_fu # if sample data is needed
$ docker-compose up
```

- You can see access web front-end in http://127.0.0.1:8901
- You can see access api in http://127.0.0.1:8900/api


After that, `docker-compose run --rm api sh`, and you can develop using shell. (firsttime, you'll be need to run `bundle install` in the shell)

Also, helper rake task `:pry` is provided.
In the shell, `docker-compose run --rm api rake pry`, and you can access ActiveRecord's models.

#### Coding style

* [EditorConfig](http://editorconfig.org/): return code, indent, charset, and more
* [yamllint](https://github.com/adrienverge/yamllint): for YAML files
* [rubocop](https://github.com/rubocop-hq/rubocop): for Ruby
* [eslint](https://eslint.org/): for JavaScript (comin soon!)

### Test

1. Install and setup CircleCI CLI
2. `circleci local execute`

or

1. `docker-compose run --rm api bundle exec rake db:setup`
2. `docker-compose run --rm api rspec`
