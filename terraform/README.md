# Infrastructure

## Adding a Terraform module

- Create Folder on under `module` directory
- Create `main.tf` to define resource
- Create `variables.tf`
- Create `outputs.tf`
- Add module to root folder `main.tf`
- Run `terraform init`

## Migrating to new modular structure

### Strategy

- Make adjustment to current resources
- Update naming convention
- Create new resources while keeping old
- When new resources are fully function, remove old resources.

#### Naming Convention

- `profolio-dev-<resource-name>`

commands

```sh
terraform workspace show
terraform state list
```

```sh
terraform plan -out=tfplan
terraform show tfplan
```

```sh
terraform show -json tfplan |
  jq -r '
    .resource_changes[]
    | select(.change.actions | index("delete"))
    | "\(.address): \(.change.actions | join(", "))"
  '
```

```sh
terraform init -reconfigure
```

```sh
terraform fmt -recursive
```
