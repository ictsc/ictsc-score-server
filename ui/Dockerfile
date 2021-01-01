FROM node:13.8.0-alpine

LABEL maintainer "ICTSC"
CMD ["yarn", "start"]
WORKDIR /usr/src/app

# docker-composeでui/をマウントするとnode_modules/が無くなるためyarn runが失敗する
# .yarnrcとPATHで別の場所にインストールして回避する
# https://github.com/yarnpkg/yarn/issues/7362
ENV PATH /usr/local/share/node_modules/.bin:$PATH

# pythonはnode-gyp(fiber)に必要
# CircleCI使うイメージにはgitとsshを入れておくのが推奨されている
RUN apk add --update --no-cache --virtual .build-dep g++ make python git openssh-client

ADD package.json yarn.lock .yarnrc /usr/src/app/
RUN yarn install

# 本当は消したほうが良いが、パッケージのアップデートでハマるので残す
# RUN apk del .build-dep

COPY . /usr/src/app/
RUN yarn run build
