#!/usr/bin/env bash -ue

iss_tag() {
  prefix='upluse10/ictsc-score-server'
  service="${1:? api or ui}"
  echo

  git log -1 --oneline
  commit="$(git log -1 --oneline | awk '$0=$1')"
  echo

  docker image ls | grep "${prefix}" | grep "\s${service}\s"
  src_image_hash="$(docker image ls | grep "${prefix}" | grep "\s${service}\s" | awk '$0=$3')"
  echo

  echo "service:        ${service}"
  echo "commit hash:    ${commit}"
  echo "src image hash: ${src_image_hash}"

  echo
  image_name="${prefix}:${service}-${commit}"
  docker tag "${src_image_hash}" "${image_name}"

  echo "docker push ${image_name}"
  docker push "${image_name}"
  echo "${image_name}"
}

docker-compose build --parallel api ui

iss_tag api
iss_tag ui
