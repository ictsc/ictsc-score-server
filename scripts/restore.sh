#!/bin/sh

filename="${1:?dump name}"

script_dir=$(cd $(dirname $0); pwd)
source "${script_dir}/../.env"

container_id="$(docker ps --filter='name=score-server_db_1' --format '{{ .ID }}')"

echo 'drop schema public cascade; create schema public;' | docker exec -i "${container_id}" psql -U "${POSTGRES_USER}" "${RAILS_ENV}"
cat "${filename}" | docker exec -i "${container_id}" psql -U postgres "${RAILS_ENV}"
