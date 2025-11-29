# terraform-azure-multiple-workspace-environment

This repository contains Terraform configuration to create Azure infrastructure across multiple workspaces/environments (for example `dev` and `prod`). It is organized using small, focused modules for networking, resource groups, and compute resources.

## Contents

- `providers.tf` - AzureRM provider configuration (currently in this repo it contains hard-coded credentials; see Security notes).
- `main.tf`, `variables.tf`, `locals.tf`, `terraform.tfvars` - top-level orchestration and variable inputs.
- `modules/` - reusable modules:
  - `compute/virtualMachines/` - VM related resources
  - `general/resourcegroup/` - resource group(s)
  - `networking/vnet/` - virtual network resources
- `terraform.tfstate`, `terraform.tfstate.backup`, `terraform.tfstate.d/` - local state files created by Terraform (if using local state).

## Quick contract

- Inputs: Terraform variables defined in `variables.tf` and `terraform.tfvars`.
- Outputs: module outputs collected in `outputs.tf` files.
- Success: `terraform apply` finishes without errors and resources appear in the configured Azure subscription.

## Prerequisites

- Terraform (compatible with provider version used in `providers.tf`; provider is pinned to `azurerm` v4.9.0 in this repo). Use Terraform >= 1.0.
- Azure CLI (recommended) or a service principal with permissions to create the desired resources.
- PowerShell (Windows) is used in sample commands below.

## Recommended workflow (PowerShell)

1. Authenticate to Azure (recommended):

```powershell
az login
az account set --subscription "<SUBSCRIPTION_ID or NAME>"
```

2. Prefer environment-based authentication (do NOT commit credentials into `providers.tf`). Example using a service principal in PowerShell:

```powershell
# $env:ARM_CLIENT_ID = 'your-client-id'
# $env:ARM_CLIENT_SECRET = 'your-client-secret'
# $env:ARM_TENANT_ID = 'your-tenant-id'
# $env:ARM_SUBSCRIPTION_ID = 'your-subscription-id'
```

3. Initialize Terraform (run once or after provider changes):

```powershell
terraform init
```

4. (Optional) Create/select a workspace (this repo contains `terraform.tfstate.d/dev/` and `prod/` structure):

```powershell
terraform workspace list
terraform workspace new dev         # if you need a new workspace
terraform workspace select dev
```

5. Validate, plan, and apply:

```powershell
terraform fmt -recursive
terraform validate
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```

6. To destroy (be careful):

```powershell
terraform destroy
```

## Notes about the provider credentials

The current `providers.tf` file in this repository contains explicit `client_id`, `client_secret`, `tenant_id`, and `subscription_id` values. Storing secrets in plain text is unsafe. Recommended approaches:

- Use environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID) and remove credentials from `providers.tf`.
- Use Azure CLI authentication (`az login`) and let the provider authenticate via CLI where supported.
- Use Managed Identity when running in an Azure host (VM, App Service, CI runner with managed identity enabled).
- Use a secure remote backend for state (see Next steps) and protect credentials with your secret manager.

Before committing changes, remove any secrets from `providers.tf` and add `providers.tf` to `.gitignore` if you must keep a local version temporarily.

## State and backend

This repository currently contains local state files (`terraform.tfstate`). For team collaboration and safety, use a remote state backend such as an Azure Storage account with a container and access controlled via RBAC. Example backend (recommended): `azurerm` backend using a storage account and container.

## Folder structure summary

```
.
├─ providers.tf
├─ main.tf
├─ variables.tf
├─ terraform.tfvars
├─ locals.tf
├─ terraform.tfstate
├─ modules/
│  ├─ compute/virtualMachines/
│  ├─ general/resourcegroup/
│  └─ networking/vnet/
└─ terraform.tfstate.d/
   ├─ dev/
   └─ prod/
```

## Suggested improvements / next steps

- Move state to an `azurerm` remote backend (Azure Storage account) and enable locking with a Cosmos DB or Storage lease.
- Remove hard-coded credentials and use environment variables or Azure AD auth.
- Add CI/CD pipeline (GitHub Actions or Azure Pipelines) that runs `terraform fmt`, `terraform validate`, `terraform plan` and stores plans as artifacts. Use secure secrets for Azure service principal credentials or add OIDC-based short-lived tokens to avoid storing long-lived secrets.
- Add module README files and inline documentation for variables and outputs.

## Security checklist

- Remove credentials from `providers.tf`.
- Add `terraform.tfstate` and any files containing secrets to `.gitignore` if they are not already excluded from VCS.
- Use least privilege for service principal used for automation.


