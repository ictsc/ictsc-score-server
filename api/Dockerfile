FROM ruby:2.7.2-slim
LABEL maintainer "ICTSC"

RUN apt-get update -y -qq \
  && apt-get upgrade -y -qq \
  && apt-get install -y -qq build-essential libpq-dev wget git tzdata shared-mime-info \
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

# bundle binstubs にパスを通す
ENV PATH /usr/src/app/bin:$PATH

# CircleCIとの関係
# このプロジェクトではお金をかけずにCIを高速化するために、
# CI上で環境を構築する際にDocker Hubからこのイメージを取得し、
# 依存gemの差分のみインストールしている。
#
# そのためベースイメージを更新した場合やOSのパッケージ構成を変えた場合は、
# CIの実行前にDocker Hubにpushしておく必要がある。
