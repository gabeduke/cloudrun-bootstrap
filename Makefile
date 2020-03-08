SERVICE_NAME ?= sandbox
SERVICE_LOCATION := us-east1

ZONE := leetcloud
DOMAIN := k8s.leetserve.com
FQDN = $(SERVICE_NAME).$(DOMAIN)

VAR_FILE := example.tfvars
TERRAFORM := terraform
TERRAFORM_OPTS := -var-file="$(VAR_FILE)" -var="service_name=$(SERVICE_NAME)" -var="service_location=$(SERVICE_LOCATION)" -var="domain=$(FQDN)"
TERRAFORM_PATH := $(CURDIR)/terraform

.terraform:
	$(TERRAFORM) init $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

terraform.tfstate: .terraform
	$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_cloud_run_service.service $(SERVICE_LOCATION)/$(SERVICE_NAME)
	$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_cloud_run_domain_mapping.service $(SERVICE_LOCATION)/$(FQDN)
	$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_dns_managed_zone.$(ZONE) $(ZONE)
	$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_dns_record_set.cname $(ZONE)/$(SERVICE_NAME)/cname

clean:
	rm -rf .terraform

import: terraform.tfstate

plan: .terraform
	$(TERRAFORM) plan $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

apply: plan
	$(TERRAFORM) apply $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

destroy: terraform.tfstate
	$(TERRAFORM) state rm google_dns_managed_zone.$(ZONE)
	$(TERRAFORM) destroy $(TERRAFORM_OPTS) $(TERRAFORM_PATH)
