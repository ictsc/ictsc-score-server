#!/usr/bin/env bash -ue

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE:-$0}")" && pwd)"

git checkout master
git pull
. ${script_dir}/build-for-deploy.sh
