# terraform-packer-weave

Spawn infrastructure to play around with [Weave Net](https://www.weave.works/docs/net/latest/overview/).

## Prerequisite

Install [direnv](https://direnv.net/).

Copy `.envrc.example` to `.envrc` and populate environment variables.

```
cp .envrc.example .envrc
```

Populate all required environment variables `.envrc`, and then run:

```
direnv allow
```

## Create an AMI

```bash
# Install packer
make ./bin/packer

make build-ami
```

## Provision instances

```bash
# Install terraform
make ./bin/terraform

make apply
```
