#!/bin/sh

# pryでAPIを操作する
docker-compose run --rm api pry --exec='require_relative "pry_r"'
