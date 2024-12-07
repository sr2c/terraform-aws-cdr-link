SHELL := /bin/bash

export HELP_FILTER ?= help|terraform|lint

# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md docs/terraform.md

-include $(shell curl -sSL -o .build-harness-ext "https://go.sr2.uk/build-harness"; echo .build-harness-ext)

## Lint terraform code
lint:
	$(SELF) terraform/install terraform/get-modules terraform/lint terraform/validate tflint

