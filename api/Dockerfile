FROM ruby:2.5.3-alpine3.8

LABEL maintainer "ICTSC"

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# Wait for DB and Redis
ENV DOCKERIZE_VERSION v0.6.1
RUN wget -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzv -C /usr/local/bin

WORKDIR /usr/src/app

# required to build native extension of mysql2 gem and more
RUN apk update \
 && apk add --virtual .build-dep build-base mariadb-connector-c-dev \
 && apk add less mariadb-connector-c tzdata \
 && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone \
 && apk del tzdata

ADD Gemfile /usr/src/app
ADD Gemfile.lock /usr/src/app

# install to default path
RUN bundle install --jobs=4

# build --squashでサイズ減少
RUN apk del .build-dep
RUN rm -rf /var/cache/apk/*

COPY . /usr/src/app

EXPOSE 3000

CMD ["rackup", "-o", "0.0.0.0", "-p", "3000"]
