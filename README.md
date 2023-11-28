# terraform-packer-weave

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

make packer-build
```
