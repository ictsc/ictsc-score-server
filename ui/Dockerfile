FROM node:13.8.0-alpine

LABEL maintainer "ICTSC"
CMD ["yarn", "start"]
WORKDIR /usr/src/app

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# docker-composeでui/をマウントするとnode_modules/が無くなるためyarn runが失敗する
# .yarnrcとPATHで別の場所にインストールして回避する
# https://github.com/yarnpkg/yarn/issues/7362
ENV PATH /usr/local/share/node_modules/.bin:$PATH

# needed because some package refers GitHub.
# RUN apk add --update --no-cache --virtual .build-dep git && apk del .build-dep

# for node-gyp
RUN apk add --no-cache --virtual .build-dep g++ make python

ADD package.json yarn.lock .yarnrc /usr/src/app/
RUN yarn install

RUN apk del .build-dep

COPY . /usr/src/app/
RUN yarn run build
