targetScope = 'subscription' // EsLZ-Connectivity

resource hubRg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'nic-hub-rg'
  location: 'swedencentral'
}

var vnetCidr = '10.0.0.0/16'

module hubVnet '../Modules/virtualNetwork_basic.bicep' = {
  scope: hubRg
  params: {
    name: 'nic-hub-vnet'
    location: hubRg.location
    addressPrefixes: [
      vnetCidr
    ]
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: cidrSubnet(vnetCidr, 24, 0)
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: cidrSubnet(vnetCidr, 24, 1)
      }
    ]
  }
}
