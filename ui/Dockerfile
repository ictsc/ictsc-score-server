FROM node:12.4.0-alpine

LABEL maintainer "ICTSC"

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8


# docker-composeでui/をマウントするとnode_modules/が無くなるためyarn runが失敗する
# .yarnrcとPATHで別の場所にインストールして回避する
# https://github.com/yarnpkg/yarn/issues/7362
ENV PATH /usr/local/share/node_modules/.bin:$PATH

WORKDIR /usr/src/app

# needed because some package refers GitHub.
# RUN apk add --update --no-cache --virtual .build-dep git && apk del .build-dep

ADD package.json yarn.lock .yarnrc /usr/src/app/
RUN yarn install

COPY . /usr/src/app/
RUN yarn run build

CMD ["yarn", "start"]
