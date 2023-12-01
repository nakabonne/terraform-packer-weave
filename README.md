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

Set the created AMI ID to `TF_VAR_ami_id` in your `.envrc`, and then:

```bash
# Set the created AMI ID
cat >> .envrc <<EOF
export TF_VAR_ami_id="<CREATED_AMI_ID>"
EOF

direnv allow

# Install terraform
make ./bin/terraform

make apply
```
