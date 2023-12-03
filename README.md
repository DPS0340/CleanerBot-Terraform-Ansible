# CleanerBot Over Lightsail using Terraform & Ansible

## How to Clone?

```
git clone https://github.com/DPS0340/Cleanerbot-Terraform-Ansible --recurse-submodules
```

## Install dependencies using nix

Make sure your nix package manager installed!

```
./install-dependencies.sh
```

## CleanerBot token setup

```
export CLEANERBOT_TOKEN=$YOUR_TOKEN
```

## Init SSH key for Lightsail

```
./init-ssh-key.sh
```

## Terraform Init

```
./init.sh
```

## Provision CleanerBot over Lightsail instance

```
./create.sh
```

## Destroy CleanerBot over Lightsail instance

```
./destroy.sh
```
