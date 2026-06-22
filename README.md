# Guestbook - ASP.NET Core + Azure Container Apps

Prosta aplikacja ASP.NET Core 9.0 z SQL Server, deployowana na Azure Container Apps z enterprise-grade pipeline'ami.

## 🏗️ Architektura

**Zasada:** Separacja obowiązków - Terraform tylko infra, pipeline'y zarządzają aplikacją.

```
Git Push (src/)        →  app-build.yml  →  docker build + push ACR  →  image:dev-{SHA}
                                              ↓
                                         Manual trigger
                                              ↓
                                         app-deploy.yml  →  az containerapp update


Git Push (infra/)      →  infra-plan.yml  →  terraform plan (PR comment)
                                              ↓
                                         Manual trigger
                                              ↓
                                         infra-apply.yml  →  terraform apply
```

## 🔐 Bezpieczeństwo

- ✅ **OIDC** — Brak AZURE_CLIENT_SECRET, wszystko przez Federated Credentials
- ✅ **Managed Identity** — Container App czyta z Key Vault bezpośrednio
- ✅ **RBAC** — Least privilege dla każdej identity
- ✅ **Image immutability** — Jeden obraz przez dev→stage→prod

## 📁 Struktura

```
infra/envs/{dev,stage,prod}/        # Environment-specific Terraform
  ├── main.tf
  ├── providers.tf                    # OIDC + Azure backend
  └── terraform.tfvars               # image_tag: initial

infra/modules/                       # Reusable modules
  ├── container-app/                 # MUST: Add Managed Identity
  ├── container-registry/
  ├── key-vault/
  └── ...

.github/workflows/
  ├── infra-plan.yml
  ├── infra-apply.yml
  ├── app-build.yml
  └── app-deploy.yml
```

## 🚀 Setup - 4 Fazy

### Faza 1: Azure (One-time, 30 min)

```bash
# 1. App Registration
az ad app create --display-name "github-actions-guestbook"
# Note: Client ID, Tenant ID, Subscription ID

# 2. Storage Account dla Terraform state
az storage account create --name sttfstatedev --resource-group rg-terraform-state-dev --location polandcentral --sku Standard_LRS
az storage container create --name terraform --account-name sttfstatedev

# 3. Federated Credentials (repeat dla stage/prod)
az identity federated-credential create \
  --identity-name github-actions-guestbook \
  --name guestbook-dev \
  --issuer https://token.actions.githubusercontent.com \
  --subject repo:YOUR_ORG/guestbook:environment:dev \
  --audiences api://AzureADTokenExchange

# 4. Role assignment
az role assignment create --role "Contributor" --assignee-object-id <APP_REG_OID> --scope /subscriptions/<SUB_ID>
az role assignment create --role "Storage Blob Data Contributor" --assignee-object-id <APP_REG_OID> --scope /subscriptions/<SUB_ID>/resourceGroups/rg-terraform-state-dev/providers/Microsoft.Storage/storageAccounts/sttfstatedev
```

### Faza 2: GitHub (One-time, 15 min)

1. **Utwórz Environments:** Settings → Environments
   - `dev` (no approvals)
   - `stage` (1 reviewer)
   - `prod` (2 reviewers)

2. **Environment Variables** (dla każdego env, zmień sufiks):
   ```
   AZURE_CLIENT_ID=<value>
   AZURE_TENANT_ID=<value>
   AZURE_SUBSCRIPTION_ID=<value>
   TF_STATE_RESOURCE_GROUP=rg-terraform-state-dev
   TF_STATE_STORAGE_ACCOUNT=sttfstatedev
   TF_STATE_CONTAINER=terraform
   KEY_VAULT_NAME=kv-guestbook-dev
   AZURE_REGISTRY_NAME=acrguestbookdev
   AZURE_CONTAINER_APP_NAME=app-guestbook-dev
   AZURE_RESOURCE_GROUP=rg-guestbook-dev
   ```

3. **Copy 4 workflow files** → `.github/workflows/` (patrz sekcja poniżej)

### Faza 3: Terraform (1 godzina)

```bash
# 1. Struktura: envs zamiast environments
mkdir -p infra/envs/{dev,stage,prod}
mv infra/environments/dev/* infra/envs/dev/
cp -r infra/envs/dev/* infra/envs/stage/
cp -r infra/envs/dev/* infra/envs/prod/
```

**Wymagane zmiany (patrz sekcja "Terraform Changes"):**
- ✅ `providers.tf` — OIDC + Azure backend
- ✅ `terraform.tfvars` — image_tag: initial (nie latest)
- ✅ `container-app/` — Managed Identity + Key Vault refs
- ✅ `main.tf` — RBAC assignments

### Faza 4: Initial Deployment (1 dzień)

```bash
# 1. Terraform (dev)
gh workflow run infra-apply.yml -f environment=dev
# Czekaj na completion

# 2. Build app (automatic na push src/)
git push origin feature/...
# Zanotuj image: dev-{SHA}

# 3. Deploy (dev)
gh workflow run app-deploy.yml -f environment=dev -f image-tag=dev-{SHA}

# 4. Setup Key Vault
az keyvault secret set --vault-name kv-guestbook-dev \
  --name ConnectionStrings--DefaultConnection \
  --value "Server=...;Database=...;User Id=...;Password=...;"

# 5. Repeat dla stage i prod (SAME IMAGE!)
```

## 🔧 Terraform Changes

### 1. Container App - Managed Identity

**`infra/modules/container-app/main.tf`:**

```hcl
# Dodaj User-Assigned Identity
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.common_tags
}

# W azurerm_container_app dodaj:
identity {
  type         = "UserAssigned"
  identity_ids = [azurerm_user_assigned_identity.container_app.id]
}

# W template.container - Key Vault secrets:
dynamic "env" {
  for_each = var.key_vault_secrets != null ? var.key_vault_secrets : []
  content {
    name  = env.value.env_name
    value = "secretref:${env.value.secret_name}"
  }
}
```

**`infra/modules/container-app/variables.tf`:**

```hcl
variable "key_vault_secrets" {
  type = list(object({
    env_name    = string
    secret_name = string
  }))
  default = null
}
```

**`infra/modules/container-app/outputs.tf`:**

```hcl
output "identity_principal_id" {
  value = azurerm_user_assigned_identity.container_app.principal_id
}
```

### 2. Providers - OIDC Setup

**`infra/envs/dev/providers.tf`:**

```hcl
terraform {
  required_version = ">= 1.8"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.100" }
  }
  backend "azurerm" { use_oidc = true }
}

provider "azurerm" {
  features { key_vault { purge_soft_delete_on_destroy = true } }
  use_oidc = true
}
```

### 3. Image Tag

**`infra/envs/dev/terraform.tfvars`:**

```hcl
image_tag = "initial"  # NOT "latest" — app-deploy.yml updates this
```

### 4. RBAC Assignments

**`infra/envs/dev/main.tf`:**

```hcl
# Container App MI → ACR
resource "azurerm_role_assignment" "container_app_acr_pull" {
  scope              = module.container_registry.acr_id
  role_definition_name = "AcrPull"
  principal_id       = module.container_app.identity_principal_id
}

# Container App MI → Key Vault
resource "azurerm_role_assignment" "container_app_kv" {
  scope              = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id       = module.container_app.identity_principal_id
}
```

### 5. Stage/Prod terraform.tfvars

```hcl
# infra/envs/stage/terraform.tfvars
resource_group_name         = "rg-guestbook-stage"
container_registry_name     = "acrguestbookstage"
container_app_name          = "app-guestbook-stage"
key_vault_name              = "kv-guestbook-stage"
sql_server_name             = "sqlserver-guestbook-stage"
# ... zmień sufiks

# infra/envs/prod/terraform.tfvars
resource_group_name         = "rg-guestbook-prod"
acr_sku                     = "Standard"  # wyższa SKU
sql_sku_name                = "Standard"
# ... zmień sufiks
```

## 📋 GitHub Workflows

Skopiuj zawartość do `.github/workflows/` (4 pliki):

1. **`infra-plan.yml`** — `terraform plan` na PR'ach, wykrywa zmienione env'y
2. **`infra-apply.yml`** — Manual `terraform apply` (stage/prod: approval required)
3. **`app-build.yml`** — Docker build + push ACR, tag: `dev-{SHA}`
4. **`app-deploy.yml`** — `az containerapp update`, health check z retry

**Zawartość workflow'ów:** Patrz [WORKFLOWS.md](docs/WORKFLOWS.md) (lub poniżej)

---

## 🎯 Workflow Reference

### `infra-plan.yml`

```yaml
name: Infrastructure Plan
on:
  pull_request:
    paths: ['infra/**']
  workflow_dispatch:
    inputs:
      environment: { type: choice, options: [dev, stage, prod] }

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'dev' }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      - run: |
          cd infra/envs/${{ github.event.inputs.environment || 'dev' }}
          terraform init \
            -backend-config="resource_group_name=${{ vars.TF_STATE_RESOURCE_GROUP }}" \
            -backend-config="storage_account_name=${{ vars.TF_STATE_STORAGE_ACCOUNT }}" \
            -backend-config="container_name=${{ vars.TF_STATE_CONTAINER }}" \
            -backend-config="key=${{ github.event.inputs.environment || 'dev' }}.tfstate"
          terraform fmt -check
          terraform validate
          terraform plan
```

### `infra-apply.yml`

```yaml
name: Infrastructure Apply
on:
  workflow_dispatch:
    inputs:
      environment: { type: choice, options: [dev, stage, prod] }

permissions:
  id-token: write
  contents: read

jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      - run: |
          cd infra/envs/${{ github.event.inputs.environment }}
          terraform init \
            -backend-config="resource_group_name=${{ vars.TF_STATE_RESOURCE_GROUP }}" \
            -backend-config="storage_account_name=${{ vars.TF_STATE_STORAGE_ACCOUNT }}" \
            -backend-config="container_name=${{ vars.TF_STATE_CONTAINER }}" \
            -backend-config="key=${{ github.event.inputs.environment }}.tfstate"
          terraform validate
          terraform plan -out=tfplan
          terraform apply tfplan
```

### `app-build.yml`

```yaml
name: Application Build
on:
  push:
    branches: [main]
    paths: ['src/**', 'Dockerfile', '.github/workflows/app-build.yml']

permissions:
  id-token: write
  contents: read

env:
  IMAGE_NAME: guestbook
  IMAGE_TAG: dev-${{ github.sha }}

jobs:
  build:
    runs-on: ubuntu-latest
    environment: dev
    outputs:
      image-tag: ${{ env.IMAGE_TAG }}
      image-uri: ${{ steps.image.outputs.uri }}
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      - run: |
          LOGIN_SERVER="${{ vars.AZURE_REGISTRY_NAME }}.azurecr.io"
          USERNAME=$(az acr credential show --name ${{ vars.AZURE_REGISTRY_NAME }} --query 'username' -o tsv)
          PASSWORD=$(az acr credential show --name ${{ vars.AZURE_REGISTRY_NAME }} --query 'passwords[0].value' -o tsv)
          echo "::add-mask::${USERNAME}"
          echo "::add-mask::${PASSWORD}"
          echo "login_server=${LOGIN_SERVER}" >> $GITHUB_ENV
          echo "username=${USERNAME}" >> $GITHUB_ENV
          echo "password=${PASSWORD}" >> $GITHUB_ENV
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.login_server }}
          username: ${{ env.username }}
          password: ${{ env.password }}
      - uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ env.login_server }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
      - id: image
        run: echo "uri=${{ env.login_server }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}" >> $GITHUB_OUTPUT
```

### `app-deploy.yml`

```yaml
name: Application Deploy
on:
  workflow_dispatch:
    inputs:
      environment: { type: choice, options: [dev, stage, prod] }
      image-tag: { description: 'Image tag', required: true }

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    steps:
      - uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      - run: |
          az acr repository show-tags \
            --name ${{ vars.AZURE_REGISTRY_NAME }} \
            --repository guestbook \
            --query "[?contains(@, '${{ github.event.inputs.image-tag }}')]" | grep -q '${{ github.event.inputs.image-tag }}' || exit 1
      - run: |
          az containerapp update \
            --name ${{ vars.AZURE_CONTAINER_APP_NAME }}-${{ github.event.inputs.environment }} \
            --resource-group ${{ vars.AZURE_RESOURCE_GROUP }} \
            --image ${{ vars.AZURE_REGISTRY_NAME }}.azurecr.io/guestbook:${{ github.event.inputs.image-tag }}
      - run: sleep 15
      - run: |
          FQDN=$(az containerapp show \
            --name ${{ vars.AZURE_CONTAINER_APP_NAME }}-${{ github.event.inputs.environment }} \
            --resource-group ${{ vars.AZURE_RESOURCE_GROUP }} \
            --query 'properties.configuration.ingress.fqdn' -o tsv)
          
          for i in {1..12}; do
            curl -sf "https://${FQDN}/health" && exit 0 || curl -sf "https://${FQDN}/" && exit 0 || true
            [ $i -lt 12 ] && sleep 10
          done
          exit 1
```

---

## 🔐 Key Vault Setup

```bash
# Sekrety (dla każdego env)
az keyvault secret set --vault-name kv-guestbook-dev \
  --name ConnectionStrings--DefaultConnection \
  --value "Server=...;Database=...;User Id=...;Password=...;"

az keyvault secret set --vault-name kv-guestbook-dev \
  --name ApiKey--ThirdParty \
  --value "***"
```

## 📊 Environment Variables Summary

```
# Dev
AZURE_CLIENT_ID=<APP_REG_CLIENT_ID>
AZURE_TENANT_ID=<TENANT_ID>
AZURE_SUBSCRIPTION_ID=<SUB_ID>
TF_STATE_RESOURCE_GROUP=rg-terraform-state-dev
TF_STATE_STORAGE_ACCOUNT=sttfstatedev
TF_STATE_CONTAINER=terraform
KEY_VAULT_NAME=kv-guestbook-dev
AZURE_REGISTRY_NAME=acrguestbookdev
AZURE_CONTAINER_APP_NAME=app-guestbook-dev
AZURE_RESOURCE_GROUP=rg-guestbook-dev

# Stage/Prod: Change -dev suffix to -stage/-prod
```

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| Federated credential not found | Verify: `repo:ORG/guestbook:environment:dev` format |
| terraform init fails (backend) | Check: `az role assignment list --assignee <APP_REG_OID>` |
| app-deploy fails (image not found) | Check: `az acr repository show-tags --name acrguestbookdev --repository guestbook` |
| Health check timeout | Increase `MAX_ATTEMPTS` or `RETRY_DELAY` in app-deploy.yml |

## 📚 Resources

- [GitHub OIDC with Azure](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure Federated Identity](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation)
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
