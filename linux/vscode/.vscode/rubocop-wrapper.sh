#!/bin/bash
docker compose run --rm -e RUBYOPT='-W0' app rubocop "$@"
