FROM ruby:2.7.2-slim
LABEL maintainer "ICTSC"

# CIが面倒くさいのでbuild-essentialなども消さない
RUN apt-get update -y -qq \
  && apt-get install -y -qq build-essential libpq-dev wget git tzdata \
  && apt-get clean \
  && rm -rf /var/lib/opt/lists/*

# Wait for DB and Redis
ENV DOCKERIZE_VERSION v0.6.1
RUN wget --quiet -O - https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz | tar xzv -C /usr/local/bin

RUN gem install bundler

WORKDIR /usr/src/app

ADD Gemfile /usr/src/app
ADD Gemfile.lock /usr/src/app

# Install to default path
RUN bundle install --jobs=4

COPY . /usr/src/app
