IMAGE := singlelog-tools

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## Format the Terraform
	terraform fmt -recursive

.PHONY: validate
validate: ## Init (no backend) and validate the Terraform
	terraform init -backend=false
	terraform fmt -check -recursive
	terraform validate

.PHONY: lint
lint: ## Run tflint
	tflint --init --config=$(CURDIR)/.tflint.hcl
	tflint --config=$(CURDIR)/.tflint.hcl

.PHONY: security
security: ## Scan the Terraform with Trivy
	trivy config .

.PHONY: cost
cost: ## Estimate monthly cost with Infracost
	infracost breakdown --path . --show-skipped --usage-file infracost-usage.yml

.PHONY: tools-build
tools-build: ## Build the pinned toolchain image
	docker build -t $(IMAGE) .

.PHONY: shell
shell: tools-build ## Open a shell in the toolchain image
	docker run --rm -it -v "$(CURDIR)":/work -w /work $(IMAGE) bash

CINC_IMAGE := cincproject/auditor:7

# Runs CINC Auditor from its own image (only Docker needed, no local install),
# mounting the profiles read-only and your private key.
define cinc_audit
	docker run --rm -v "$(CURDIR)/inspec":/inspec:ro -v "$(abspath $(KEY))":/key:ro $(CINC_IMAGE) \
		exec /inspec/$(1) -t ssh://ubuntu@$(HOST) -i /key --no-create-lockfile --chef-license accept-silent
endef

.PHONY: audit-nginx
audit-nginx: ## CINC Auditor checks on the nginx host (HOST=<ip> KEY=<private key>)
	$(call cinc_audit,nginx)

.PHONY: audit-clickhouse
audit-clickhouse: ## CINC Auditor checks on the ClickHouse host (HOST=<ip> KEY=<private key>)
	$(call cinc_audit,clickhouse)
