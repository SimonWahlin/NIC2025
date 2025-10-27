$CreateParameters = @{
    Name                       = 'DeploySpoke4'
    Location                   = 'SwedenCentral'
    TemplateFile               = '2.Spoke/SpokeVnet.bicep'
    TemplateParameterObject    = @{
        number = '4'
    }
    Force                      = $true
    ActionOnUnmanage           = 'DeleteAll'
    DenySettingsMode           = 'DenyWriteAndDelete'
    DenySettingsExcludedAction = @(
        #'Microsoft.Network/networkSecurityGroups/write',
        #'Microsoft.Network/networkSecurityGroups/securityRules/write',
        #'Microsoft.Network/virtualNetworks/subnets/write',
        'Microsoft.Network/networkSecurityGroups/join/action',
        'Microsoft.Network/routeTables/join/action',
        'Microsoft.Network/virtualNetworks/join/action'
    )
    ManagementGroupId = 'EsLz-corp'
    DeploymentSubscriptionId = '5eedf5dd-eeef-479f-b801-89ec1c780208' #LZ1
}
New-AzManagementGroupDeploymentStack @CreateParameters















<#
$RemoveParameters = @{
    Name             = $CreateParameters.Name
    Force            = $true
    ActionOnUnmanage = 'DeleteAll'
    ManagementGroupId = $CreateParameters.ManagementGroupId
}
Remove-AzManagementGroupDeploymentStack @RemoveParameters
#>




