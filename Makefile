UNAME := $(shell uname)
TERRAFORM_VERSION=1.5.3

./bin/packer:
	@mkdir -p bin
ifeq ($(UNAME), Linux)
	cd bin && curl -o packer.zip https://releases.hashicorp.com/packer/1.9.4/packer_1.9.4_linux_amd64.zip && unzip packer.zip && rm packer.zip
	@chmod +x ./bin/packer
else ifeq ($(UNAME), Darwin)
  # Download ARM version
	cd bin && curl -o packer.zip https://releases.hashicorp.com/packer/1.9.4/packer_1.9.4_darwin_arm64.zip && unzip packer.zip && rm packer.zip
	@chmod +x ./bin/packer
else
	@echo "Unsupported OS, please copy your local packer binary manually to ./bin/packer"
	@exit 1
endif

./bin/terraform:
	@mkdir -p bin
ifeq ($(UNAME), Linux)
	cd bin && curl -o terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_386.zip && unzip terraform.zip && rm terraform.zip
	@chmod +x ./bin/terraform
else ifeq ($(UNAME), Darwin)
	cd bin && curl -o terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_darwin_amd64.zip && unzip terraform.zip && rm terraform.zip
	@chmod +x ./bin/terraform
else
	@echo "Unsupported OS, please copy your local terraform binary manually to ./bin/terraform"
	@exit 1
endif

build-ami:
	@cd packer && packer init . && packer fmt . && packer validate . && packer build weave.pkr.hcl

apply:
	@cd terraform && terraform init && terraform fmt && terraform validate && terraform plan && terraform apply
