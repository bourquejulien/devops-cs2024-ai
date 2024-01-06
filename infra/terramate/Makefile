OPTIONS=--disable-check-git-uncommitted
OPTIONS+=--disable-check-git-untracked
PLAN_NAME=plan.tfplan
DESTROY_PLAN_NAME=main.destroy.tfplan
INIT_FILES=.terraform/modules/modules.json

MODULES_FILES:=$(shell find ../modules -name '*.tf')

plan: $(PLAN_NAME)
init: $(INIT_FILES)
generate: *.tf
plan_destroy: $(DESTROY_PLAN_NAME)

apply: $(PLAN_NAME)
	terramate $(OPTIONS) run terraform apply $(PLAN_NAME)

apply_destroy: $(DESTROY_PLAN_NAME)
	terramate $(OPTIONS) run terraform apply $(DESTROY_PLAN_NAME)

.phony: generate init plan apply apply_destroy

*.tf: *.hcl
	terramate generate

$(INIT_FILES): *.tf $(MODULES_FILES)
	terramate $(OPTIONS) run terraform init

$(PLAN_NAME): $(INIT_FILES)
	terramate $(OPTIONS) run terraform plan -out $@

$(DESTROY_PLAN_NAME): $(INIT_FILES)
	terramate $(OPTIONS) run terraform plan -destroy -out $@
