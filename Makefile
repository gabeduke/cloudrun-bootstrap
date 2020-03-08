SERVICE_NAME := sandbox
SERVICE_LOCATION := us-east1

VAR_FILE := example.tfvars
TERRAFORM := terraform
TERRAFORM_OPTS := -var-file="$(VAR_FILE)" -var="service_name=$(SERVICE_NAME)" -var="service_location=$(SERVICE_LOCATION)"
TERRAFORM_PATH := $(CURDIR)/terraform

.terraform:
	$(TERRAFORM) init $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

terraform.tfstate: .terraform
	$(TERRAFORM) import -config $(TERRAFORM_PATH) $(TERRAFORM_OPTS) google_cloud_run_service.service $(SERVICE_LOCATION)/$(SERVICE_NAME) | true

clean:
	rm -rf .terraform

plan: terraform.tfstate
	$(TERRAFORM) plan $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

apply: plan
	$(TERRAFORM) apply $(TERRAFORM_OPTS) $(TERRAFORM_PATH)

destroy: terraform.tfstate
	$(TERRAFORM) destroy $(TERRAFORM_OPTS) $(TERRAFORM_PATH)
