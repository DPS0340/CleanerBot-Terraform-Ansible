#!/usr/bin/env bash

envsubst < .env.template > .env
source .env
yes yes | terraform destroy
