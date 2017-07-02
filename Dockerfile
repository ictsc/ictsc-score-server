FROM ruby:2.4.1-alpine

LABEL maintainer "kyontan <kyontan@monora.me>"

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

WORKDIR /usr/src/app

ADD Gemfile /usr/src/app
ADD Gemfile.lock /usr/src/app

# required to build native extension of mysql2 gem
RUN apk update \
 && apk add --virtual .build-dep \
        build-base \
        mariadb-dev \
 && apk add --virtual .running-dep \
        mariadb-client-libs \
 && bundle install --jobs=4 \
 && apk del .build-dep \
 && rm -rf /var/cache/apk/*

COPY . /usr/src/app

EXPOSE 3000

CMD ["rackup", "-o", "0.0.0.0", "-p", "3000"]
