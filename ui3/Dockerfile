FROM node:12.4.0-alpine

LABEL maintainer "ICTSC"

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

WORKDIR /usr/src/app

# needed because some package refers GitHub.
# RUN apk add --update --no-cache --virtual .build-dep git && apk del .build-dep

ADD package.json yarn.lock /usr/src/app/
RUN yarn install

COPY . /usr/src/app/
RUN yarn run build

CMD ["yarn", "start"]
