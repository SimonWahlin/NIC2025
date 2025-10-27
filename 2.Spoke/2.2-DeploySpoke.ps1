$CreateParameters = @{
    Name                    = 'DeploySpoke2'
    Location                = 'SwedenCentral'
    TemplateFile            = '2.Spoke/SpokeVnet.bicep'
    TemplateParameterObject = @{
        number = '2'
    }
    Force                   = $true
    ActionOnUnmanage        = 'DeleteAll'
    DenySettingsMode        = 'None'
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




