# Script to list all policy assignments and export
#Connect to Azure account
Connect-AzAccount

# Get all policy assignments
$policyAssignments = Get-AzPolicyAssignment

# Get management groups and handle cases where none are found
$managementGroups = Get-AzManagementGroup
if ($null -eq $managementGroups -or $managementGroups.Count -eq 0) {
    $warningMessage = "No management groups found. Skipping management group policy assignments."
    Write-Warning $warningMessage
    # Log the warning to a file
    Add-Content -Path "PolicyAssignments.log" -Value "$(Get-Date): $warningMessage"
} else {
    $policyAssignments += foreach ($mg in $managementGroups) {
        Get-AzPolicyAssignment -Scope $mg.Id
    }
}

# Export policy assignments to a CSV file
$outputFile = "PolicyAssignments.csv"
$policyAssignments | Select-Object DisplayName, PolicyDefinitionId, Scope, NotScopes, Parameters, Id | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Policy assignments have been exported to $outputFile"
# Log the success message
Add-Content -Path "PolicyAssignments.log" -Value "$(Get-Date): Policy assignments exported to $outputFile"
# Open the CSV file automatically after export
Invoke-Item -Path $outputFile