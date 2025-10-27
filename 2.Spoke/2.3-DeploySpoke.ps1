$CreateParameters = @{
    Name                           = 'DeploySpoke3'
    Location                       = 'SwedenCentral'
    TemplateFile                   = '2.Spoke/SpokeVnet.bicep'
    TemplateParameterObject        = @{
        number = '3'
    }
    Force                          = $true
    ActionOnUnmanage               = 'DeleteAll'
    DenySettingsMode               = 'DenyWriteAndDelete'
    DenySettingsApplyToChildScopes = $false
    DenySettingsExcludedAction     = @(
        #'Microsoft.Network/networkSecurityGroups/write',
        #'Microsoft.Network/networkSecurityGroups/securityRules/write',
        #'Microsoft.Network/virtualNetworks/subnets/write',
        'Microsoft.Network/networkSecurityGroups/join/action',
        'Microsoft.Network/routeTables/join/action',
        'Microsoft.Network/virtualNetworks/join/action'
    )
    DenySettingsExcludedPrincipal = @()
}
New-AzSubscriptionDeploymentStack @CreateParameters


















<#
$RemoveParameters = @{
    Name             = $CreateParameters.Name
    Force            = $true
    ActionOnUnmanage = 'DeleteAll'
}
Remove-AzSubscriptionDeploymentStack @RemoveParameters
#>




