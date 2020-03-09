SERVICE_NAME ?= sandbox
SERVICE_LOCATION := us-east1

ZONE := leetcloud
DOMAIN := k8s.leetserve.com
FQDN = $(SERVICE_NAME).$(DOMAIN)

VAR_FILE := $(CURDIR)/example.tfvars
TERRAFORM := terraform
TERRAFORM_OPTS = -var-file="$(VAR_FILE)" -var="service_name=$(SERVICE_NAME)" -var="service_location=$(SERVICE_LOCATION)" -var="domain=$(FQDN)" $(TERRAFORM_STATE)
TERRAFORM_PATH := $(CURDIR)/terraform
TERRAFORM_STATE := -state=$(CURDIR)/$(SERVICE_NAME).tfstate

.terraform:
	$(TERRAFORM) init $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

$(SERVICE_NAME).tfstate: .terraform
	-$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_cloud_run_service.service $(SERVICE_LOCATION)/$(SERVICE_NAME)
	-$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_cloud_run_domain_mapping.service $(SERVICE_LOCATION)/$(FQDN)
	-$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_dns_managed_zone.$(ZONE) $(ZONE)
	-$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_dns_record_set.cname $(ZONE)/$(FQDN)./CNAME

clean:
	rm -rf .terraform

import: $(SERVICE_NAME).tfstate

plan: .terraform
	$(TERRAFORM) plan $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

apply: plan
	$(TERRAFORM) apply $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

destroy: $(SERVICE_NAME).tfstate
	$(TERRAFORM) state rm $(TERRAFORM_STATE) google_dns_managed_zone.$(ZONE) 
	$(TERRAFORM) destroy $(TERRAFORM_OPTS) $(TERRAFORM_PATH)
