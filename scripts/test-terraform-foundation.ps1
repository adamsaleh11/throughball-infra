$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$failures = New-Object System.Collections.Generic.List[string]

function Resolve-TerraformCommand {
    $terraform = Get-Command "terraform" -ErrorAction SilentlyContinue
    if ($terraform) {
        return $terraform.Source
    }

    $localTerraform = Join-Path $repoRoot ".tools/terraform/terraform.exe"
    if (Test-Path $localTerraform) {
        return (Resolve-Path $localTerraform).Path
    }

    return $null
}

function Invoke-CheckedTerraform {
    param(
        [string[]] $Arguments,
        [string] $Description
    )

    if (-not $script:terraformCommand) {
        $failures.Add("Terraform CLI not found for check: $Description. Install Terraform or place terraform.exe at .tools/terraform/terraform.exe.")
        return
    }

    & $script:terraformCommand @Arguments
    if ($LASTEXITCODE -ne 0) {
        $failures.Add("Terraform check failed: $Description")
    }
}

function Assert-PathExists {
    param([string] $Path)

    if (-not (Test-Path $Path)) {
        $failures.Add("Missing path: $Path")
    }
}

function Assert-FileContains {
    param(
        [string] $Path,
        [string] $Pattern,
        [string] $Description
    )

    if (-not (Test-Path $Path)) {
        $failures.Add("Missing file for content check: $Path")
        return
    }

    $content = Get-Content -Raw -Path $Path
    if ($content -notmatch $Pattern) {
        $failures.Add("$Path does not contain expected content: $Description")
    }
}

@(
    "environments/dev",
    "environments/staging",
    "environments/prod",
    "modules/cloud-run",
    "modules/secrets",
    "modules/iam",
    "modules/artifact-registry",
    "modules/observability"
) | ForEach-Object { Assert-PathExists $_ }

@(
    "environments/dev/main.tf",
    "environments/dev/variables.tf",
    "environments/dev/outputs.tf",
    "environments/dev/versions.tf",
    "environments/dev/README.md",
    "environments/dev/terraform.tfvars.example"
) | ForEach-Object { Assert-PathExists $_ }

$nonDevTfFiles = @()
if (Test-Path "environments/staging") {
    $nonDevTfFiles += Get-ChildItem -Path "environments/staging" -Filter "*.tf" -Recurse
}
if (Test-Path "environments/prod") {
    $nonDevTfFiles += Get-ChildItem -Path "environments/prod" -Filter "*.tf" -Recurse
}
if ($nonDevTfFiles.Count -gt 0) {
    $failures.Add("Staging/prod must not contain runnable Terraform files: $($nonDevTfFiles.FullName -join ', ')")
}

Assert-FileContains "environments/dev/variables.tf" 'default\s+=\s+"us-central1"' "region defaults to us-central1"
Assert-FileContains "environments/dev/variables.tf" 'var\.region\s*==\s*"us-central1"' "region validation rejects other regions"
Assert-FileContains "environments/dev/variables.tf" 'min_instances' "min_instances variable exists"
Assert-FileContains "environments/dev/variables.tf" 'default\s+=\s+0' "min_instances defaults to 0"
Assert-FileContains "environments/dev/variables.tf" 'var\.min_instances\s*==\s*0' "min_instances validation rejects nonzero values"
Assert-FileContains "environments/dev/variables.tf" 'max_instances' "max_instances variable exists"
Assert-FileContains "environments/dev/variables.tf" 'throughball-platform-api' "dev defines platform API Cloud Run service"
Assert-FileContains "environments/dev/variables.tf" 'throughball-ai-runtime' "dev defines AI runtime Cloud Run service"
Assert-FileContains "environments/dev/variables.tf" 'throughball-mcp-server' "dev defines MCP server Cloud Run service"
Assert-FileContains "environments/dev/variables.tf" 'throughball-worker' "dev defines worker Cloud Run service"
Assert-FileContains "environments/dev/variables.tf" 'max_instances\s*<=\s*1' "dev rejects Cloud Run max_instances above one"
Assert-FileContains "environments/dev/main.tf" 'google_project_service' "dev enables required APIs"
Assert-FileContains "environments/dev/main.tf" 'module\s+"artifact_registry"' "dev wires artifact registry module"
Assert-FileContains "environments/dev/main.tf" 'module\s+"iam"' "dev wires IAM module"
Assert-FileContains "environments/dev/main.tf" 'module\s+"cloud_run"' "dev wires Cloud Run module"
Assert-FileContains "environments/dev/main.tf" 'for_each\s+=\s+var\.cloud_run_services' "dev creates Cloud Run services from service map"
Assert-FileContains "environments/dev/main.tf" 'roles/secretmanager\.secretAccessor' "dev grants runtime access to referenced secrets"
Assert-FileContains "environments/dev/main.tf" 'module\s+"secrets"' "dev wires secrets module"
Assert-FileContains "environments/dev/main.tf" 'module\s+"observability"' "dev wires observability module"
Assert-FileContains "modules/cloud-run/main.tf" 'google_cloud_run_v2_service' "Cloud Run module uses v2 service"
Assert-FileContains "modules/cloud-run/main.tf" 'startup_probe' "Cloud Run module supports startup probes"
Assert-FileContains "modules/cloud-run/main.tf" 'liveness_probe' "Cloud Run module supports liveness probes"
Assert-FileContains "modules/cloud-run/main.tf" 'secret_key_ref' "Cloud Run module supports Secret Manager environment variables"
Assert-FileContains "modules/cloud-run/main.tf" 'cpu_idle' "Cloud Run module configures request-scoped CPU"
Assert-FileContains "environments/dev/outputs.tf" 'cloud_run_service_names' "dev outputs all Cloud Run service names"
Assert-FileContains "environments/dev/outputs.tf" 'cloud_run_service_uris' "dev outputs all Cloud Run service URIs"
Assert-FileContains "modules/artifact-registry/main.tf" 'google_artifact_registry_repository' "Artifact Registry module creates repository"
Assert-FileContains "modules/secrets/main.tf" 'google_secret_manager_secret' "Secrets module creates secret containers"
Assert-FileContains "modules/iam/main.tf" 'google_service_account' "IAM module creates runtime service account"
Assert-FileContains "README.md" 'terraform init' "README explains init"
Assert-FileContains "README.md" 'terraform plan' "README explains plan"
Assert-FileContains "README.md" 'terraform apply' "README explains apply"
Assert-FileContains "README.md" 'Do not apply prod|do not apply prod|DO NOT APPLY PROD' "README warns not to apply prod"
Assert-FileContains "environments/prod/README.md" 'Do not apply|DO NOT APPLY|do not apply' "prod README warns not to apply"

$script:terraformCommand = Resolve-TerraformCommand
Invoke-CheckedTerraform @("fmt", "-check", "-recursive") "terraform fmt -check -recursive"
Invoke-CheckedTerraform @("-chdir=environments/dev", "init", "-backend=false") "terraform init -backend=false from environments/dev"
Invoke-CheckedTerraform @("-chdir=environments/dev", "validate") "terraform validate from environments/dev"

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Terraform foundation checks passed."
