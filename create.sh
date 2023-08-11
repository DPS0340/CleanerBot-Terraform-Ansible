#!/usr/bin/env bash

envsubst < ansible-env.yaml.template > ansible-env.yaml

envsubst < .env.template > .env

source .env
yes yes | terraform apply
