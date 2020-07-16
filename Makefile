SHELL:=/bin/bash
TERRAFORM_VERSION=0.12.24
TERRAFORM=docker run --rm -v "${PWD}:/work" -e AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) -e http_proxy=$(http_proxy) --net=host -w /work hashicorp/terraform:$(TERRAFORM_VERSION)

.PHONY: all clean test docs format

all: test docs format

clean:
	rm -rf .terraform/

test:
	$(TERRAFORM) init && $(TERRAFORM) validate && \
		$(TERRAFORM) init modules/locally_signed && $(TERRAFORM) validate modules/locally_signed && \
		$(TERRAFORM) init modules/self_signed && $(TERRAFORM) validate modules/self_signed

docs:
	docker run --rm -v "${PWD}:/work" tmknom/terraform-docs markdown ./ >./README.md && \
		docker run --rm -v "${PWD}:/work" tmknom/terraform-docs markdown ./modules/locally_signed >./modules/locally_signed/README.md && \
		docker run --rm -v "${PWD}:/work" tmknom/terraform-docs markdown ./modules/self_signed >./modules/self_signed/README.md

format:
	$(TERRAFORM) fmt -list=true ./ && \
		$(TERRAFORM) fmt -list=true ./modules/locally_signed && \
		$(TERRAFORM) fmt -list=true ./modules/self_signed
