FROM node:8.15.0-alpine AS build-temp

LABEL maintainer "ICTSC"

WORKDIR /usr/src/app

# needed because some package refers GitHub.
RUN apk add --update --no-cache --virtual .build-dep \
        git

ADD package.json yarn.lock /usr/src/app/

RUN yarn

COPY . /usr/src/app
RUN yarn run build

FROM lkwg82/h2o-http2-server

ADD h2o/h2o.conf /etc/h2o
COPY --from=build-temp /usr/src/app/dist /public
