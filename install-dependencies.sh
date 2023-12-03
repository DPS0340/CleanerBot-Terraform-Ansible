#!/bin/bash

export NIXPKGS_ALLOW_UNFREE=1
nix-env -i -f ./packages.nix
