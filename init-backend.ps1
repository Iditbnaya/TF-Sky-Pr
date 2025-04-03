param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$true)]
    [string]$Region,

    [Parameter(Mandatory=$false)]
    [string]$KeyName = "terraform.tfstate"
)

# Login to Azure if not already logged in
$context = Get-AzContext
if (!$context) {
    Connect-AzAccount
    Set-AzContext -Subscription $SubscriptionId
} elseif ($context.Subscription.Id -ne $SubscriptionId) {
    Set-AzContext -Subscription $SubscriptionId
}

# Create resource group if it doesn't exist
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (!$rg) {
    Write-Host "Creating resource group: $ResourceGroupName"
    New-AzResourceGroup -Name $ResourceGroupName -Location $Region
}

# Create storage account if it doesn't exist
$sa = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
if (!$sa) {
    Write-Host "Creating storage account: $StorageAccountName"
    $sa = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName `
        -Location $Region `
        -SkuName Standard_LRS `
        -Kind StorageV2 `
        -EnableHttpsTrafficOnly $true `
        -MinimumTlsVersion TLS1_2
}

# Get storage account key
$keys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$key = $keys[0].Value

# Create container if it doesn't exist
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key
$container = Get-AzStorageContainer -Name $ContainerName -Context $ctx -ErrorAction SilentlyContinue
if (!$container) {
    Write-Host "Creating container: $ContainerName"
    New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Off
}

# Generate backend configuration command
Write-Host "Backend is ready. Use the following command to initialize Terraform:"
Write-Host ""
Write-Host "terraform init -backend-config=`"storage_account_name=$StorageAccountName`" -backend-config=`"container_name=$ContainerName`" -backend-config=`"key=$KeyName`" -backend-config=`"resource_group_name=$ResourceGroupName`" -backend-config=`"subscription_id=$SubscriptionId`""
Write-Host ""

# Create backend config file
$backendConfig = @"
storage_account_name  = "$StorageAccountName"
container_name        = "$ContainerName"
key                   = "$KeyName"
resource_group_name   = "$ResourceGroupName"
subscription_id       = "$SubscriptionId"
"@

$backendConfig | Out-File -FilePath "backend.conf" -Encoding utf8
Write-Host "Backend configuration saved to 'backend.conf'. You can also use:"
Write-Host "terraform init -backend-config=backend.conf" 