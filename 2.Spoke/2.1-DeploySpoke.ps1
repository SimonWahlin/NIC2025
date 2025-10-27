$CreateParameters = @{
    Name                    = 'DeploySpoke1'
    Location                = 'SwedenCentral'
    TemplateFile            = '2.Spoke/SpokeVnet.bicep'
    TemplateParameterObject = @{
        number = '1'
    }
}
New-AzDeployment @CreateParameters