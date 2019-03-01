#!/bin/bash

MYSQL_PASSWORD=""
MYSQL_ROOT_PASSWORD=""
CONTEST_FQDN=""
API_SESSION_COOKIE_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

echo -n "MYSQL_PASSWORD: "; read MYSQL_PASSWORD
echo -n "MYSQL_ROOT_PASSWORD: "; read MYSQL_ROOT_PASSWORD
echo -n "CONTEST_FQDN: "; read CONTEST_FQDN

kubectl apply -f <(cat api.yaml \
  | perl -pe 's|^(  MYSQL_ROOT_PASSWORD: )"PASSWORD"$|$1"'$MYSQL_ROOT_PASSWORD'"|g' \
  | perl -pe 's|^(  MYSQL_PASSWORD: )"PASSWORD"$|$1"'$MYSQL_PASSWORD'"|g' \
  | perl -pe 's|^(  API_SESSION_COOKIE_SECRET: )"SECRET"$|$1"'$API_SESSION_COOKIE_SECRET'"|g' \
  | perl -pe 's|^(        - )CONTEST_FQDN$|$1'$CONTEST_FQDN'|g' \
  | perl -pe 's|^(    - host: )CONTEST_FQDN$|$1'$CONTEST_FQDN'|g' \
  )


kubectl apply -f <(cat mariadb.yaml \
  | perl -pe 's|^(  MYSQL_ROOT_PASSWORD: )"PASSWORD"$|$1"'$MYSQL_ROOT_PASSWORD'"|g' \
  | perl -pe 's|^(  MYSQL_PASSWORD: )"PASSWORD"$|$1"'$MYSQL_PASSWORD'"|g' \
  )

kubectl apply -f <(cat ui.yaml \
  | perl -pe 's|^(        - )CONTEST_FQDN$|$1'$CONTEST_FQDN'|g' \
  | perl -pe 's|^(    - host: )CONTEST_FQDN$|$1'$CONTEST_FQDN'|g' \
  )

kubectl apply -f plasma.yaml
kubectl apply -f redis.yaml

