FROM node:6-alpine AS build-temp

LABEL maintainer "kyontan <kyontan@monora.me>"

WORKDIR /usr/src/app

# needed because some package refers GitHub.
RUN apk add --update --no-cache --virtual .build-dep \
        git

ADD package.json yarn.lock /usr/src/app/

RUN yarn

COPY . /usr/src/app
RUN yarn run build

FROM lkwg82/h2o-http2-server

ADD h2o.conf /etc/h2o
COPY --from=build-temp /usr/src/app/dist /public
