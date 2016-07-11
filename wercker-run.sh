#!/bin/sh

bundle install --path /pipeline/cache/bundle-install
bundle exec rackup $@
