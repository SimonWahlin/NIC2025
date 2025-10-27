metadata name = 'Virtual Network'
metadata description = 'This module deploys a Virtual Network (vNet).'
metadata owner = 'SimonWahlin'
metadata version = '0.2.0'

@description('The Virtual Network (vNet) Name.')
param name string

@description('An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array = ['10.0.0.0/24']

@description('An Array of subnets to deploy to the Virtual Network.')
param subnets subnet[] = [
  {
    name: 'subnet1'
    addressPrefix: cidrSubnet(addressPrefixes[0], 24, 0)
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupId: null
  }
]

@description('DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''

@description('Indicates if encryption is enabled on virtual network. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property.')
param vnetEncryption bool = false

@allowed([
  'AllowUnencrypted'
  'DropUnencrypted'
])
@description('If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled.')
param vnetEncryptionEnforcement string = 'AllowUnencrypted'

@maxValue(30)
@description('The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null.')
param flowTimeoutInMinutes int = 0

@description('Tags of the resource.')
param tags object = {}

@description('Location for all resources.')
param location string = resourceGroup().location

@export()
type subnet = {
  name: string
  addressPrefix: string
  @description('Optional. Set this property to false to disable default outbound connectivity for all VMs in the subnet. This property can only be set at the time of subnet creation and cannot be updated for an existing subnet')
  defaultOutboundAccess: bool?
  delegations: {
    name: string
    properties: {
      serviceName: (
        | 'Microsoft.ApiManagement/service'
        | 'Microsoft.Apollo/npu'
        | 'Microsoft.App/environments'
        | 'Microsoft.App/testClients'
        | 'Microsoft.AVS/PrivateClouds'
        | 'Microsoft.AzureCosmosDB/clusters'
        | 'Microsoft.BareMetal/AzureHostedService'
        | 'Microsoft.BareMetal/AzureVMware'
        | 'Microsoft.BareMetal/CrayServers'
        | 'Microsoft.Batch/batchAccounts'
        | 'Microsoft.CloudTest/hostedpools'
        | 'Microsoft.CloudTest/images'
        | 'Microsoft.CloudTest/pools'
        | 'Microsoft.Codespaces/plans'
        | 'Microsoft.ContainerInstance/containerGroups'
        | 'Microsoft.ContainerService/managedClusters'
        | 'Microsoft.Databricks/workspaces'
        | 'Microsoft.DBforMySQL/flexibleServers'
        | 'Microsoft.DBforMySQL/servers'
        | 'Microsoft.DBforMySQL/serversv2'
        | 'Microsoft.DBforPostgreSQL/flexibleServers'
        | 'Microsoft.DBforPostgreSQL/serversv2'
        | 'Microsoft.DBforPostgreSQL/singleServers'
        | 'Microsoft.DelegatedNetwork/controller'
        | 'Microsoft.DevCenter/networkConnection'
        | 'Microsoft.DocumentDB/cassandraClusters'
        | 'Microsoft.Fidalgo/networkSettings'
        | 'Microsoft.HardwareSecurityModules/dedicatedHSMs'
        | 'Microsoft.Kusto/clusters'
        | 'Microsoft.LabServices/labplans'
        | 'Microsoft.Logic/integrationServiceEnvironments'
        | 'Microsoft.MachineLearningServices/workspaces'
        | 'Microsoft.Netapp/scaleVolumes'
        | 'Microsoft.Netapp/volumes'
        | 'Microsoft.Network/dnsResolvers'
        | 'Microsoft.Network/networkWatchers'
        | 'Microsoft.Orbital/orbitalGateways'
        | 'Microsoft.PowerPlatform/enterprisePolicies'
        | 'Microsoft.PowerPlatform/vnetaccesslinks'
        | 'Microsoft.ServiceFabricMesh/networks'
        | 'Microsoft.ServiceNetworking/trafficControllers'
        | 'Microsoft.Singularity/accounts/networks'
        | 'Microsoft.Singularity/accounts/npu'
        | 'Microsoft.Sql/managedInstances'
        | 'Microsoft.StoragePool/diskPools'
        | 'Microsoft.StreamAnalytics/streamingJobs'
        | 'Microsoft.Synapse/workspaces'
        | 'Microsoft.Web/hostingEnvironments'
        | 'Microsoft.Web/serverFarms'
        | 'Dell.Storage/fileSystems'
        | 'GitHub.Network/networkSettings'
        | 'NGINX.NGINXPLUS/nginxDeployments'
        | 'Oracle.Database/networkAttachments'
        | 'PaloAltoNetworks.Cloudngfw/firewalls'
        | 'Qumulo.Storage/fileSystems')
    }
  }[]?
  @description('ResourceId of the NAT Gateway to be associated with the subnet.')
  natGatewayId: string?
  @description('ResourceId of the Network Security Group to be associated with the subnet.')
  networkSecurityGroupId: string?
  privateEndpointNetworkPolicies: ('Enabled' | 'RouteTableEnabled' | 'NetworkSecurityGroupEnabled' | 'Disabled' | null)?
  privateLinkServiceNetworkPolicies: ('Enabled' | 'Disabled' | null)?
  @description('ResourceId of the route table to be associated with the subnet.')
  routeTableId: string?
  serviceEndpoints: {
    service: (
      | 'Microsoft.AzureActiveDirectory'
      | 'Microsoft.AzureCosmosDB'
      | 'Microsoft.CognitiveServices'
      | 'Microsoft.ContainerRegistry'
      | 'Microsoft.EventHub'
      | 'Microsoft.KeyVault'
      | 'Microsoft.ServiceBus'
      | 'Microsoft.Sql'
      | 'Microsoft.Storage'
      | 'Microsoft.Web')
  }[]?
  serviceEndpointPolicies: {
    id: string
  }[]?
}

var dnsServersVar = {
  dnsServers: array(dnsServers)
}

var ddosProtectionPlan = {
  id: ddosProtectionPlanId
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    ddosProtectionPlan: !empty(ddosProtectionPlanId) ? ddosProtectionPlan : null
    dhcpOptions: !empty(dnsServers) ? dnsServersVar : null
    enableDdosProtection: !empty(ddosProtectionPlanId)
    encryption: vnetEncryption == true
      ? {
          enabled: vnetEncryption
          enforcement: vnetEncryptionEnforcement
        }
      : null
    flowTimeoutInMinutes: flowTimeoutInMinutes != 0 ? flowTimeoutInMinutes : null
  }
}

resource vnetSubnets 'Microsoft.Network/virtualNetworks/subnets@2024-10-01' = [
  for subnet in subnets: {
    name: subnet.name
    parent: virtualNetwork
    properties: {
      addressPrefix: subnet.addressPrefix
      defaultOutboundAccess: subnet.?defaultOutboundAccess
      delegations: subnet.?delegations ?? []
      natGateway: contains(subnet, 'natGatewayId')
        ? {
            id: subnet.?natGatewayId
          }
        : null
      networkSecurityGroup: contains(subnet, 'networkSecurityGroupId')
        ? {
            id: subnet.?networkSecurityGroupId
          }
        : null
      privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: subnet.?privateLinkServiceNetworkPolicies
      routeTable: contains(subnet, 'routeTableId')
        ? {
            id: subnet.?routeTableId
          }
        : null
      serviceEndpoints: subnet.?serviceEndpoints ?? []
      serviceEndpointPolicies: subnet.?serviceEndpointPolicies ?? []
    }
  }
]

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output subnets array = virtualNetwork.properties.subnets
