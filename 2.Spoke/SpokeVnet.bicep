targetScope = 'subscription'

param number string = ''

var vnetCidr = '10.${number}.0.0/16'
var hubVnetId = '${hubRg.id}/providers/Microsoft.Network/virtualNetworks/nic-hub-vnet'

resource hubRg 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  scope: subscription('80a13dc7-8ad1-4e86-b105-4b523b7cfcd5')
  name: 'nic-hub-rg'
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'nic-spoke${number}-rg'
  location: 'swedencentral'
}

module defaultNsg '../Modules/networkSecurityGroup.bicep' = {
  scope: spokeRg
  params: {
    name: 'nic-spoke${number}-default-nsg'
    location: spokeRg.location
    rules: [
      {
        name: 'AllowHTTPSInbound'
        properties: {
          priority: 100
          description: 'Allow HTTPS inbound traffic'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          protocol: 'Tcp'
        }
      }
      {
        name: 'AllowRDPOutbound'
        properties: {
          priority: 100
          description: 'Allow RDP outbound traffic'
          access: 'Allow'
          direction: 'Outbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          protocol: 'Tcp'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 4096
          description: 'Deny all inbound traffic'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          protocol: '*'
        }
      }
      {
        name: 'DenyAllOutbound'
        properties: {
          priority: 4096
          description: 'Deny all outbound traffic'
          access: 'Deny'
          direction: 'Outbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          protocol: '*'
        }
      }
    ]
  }
}

module defaultUDR '../Modules/routeTables.bicep' = {
  scope: spokeRg
  params: {
    name: 'nic-spoke${number}-default-udr'
    location: spokeRg.location
    routes: [
      {
        name: 'DefaultRouteHub'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.4'
        }
      }
    ]
  }
}

module spokeVnet '../Modules/virtualNetwork_basic.bicep' = {
  scope: spokeRg
  params: {
    name: 'nic-spoke${number}-vnet'
    location: spokeRg.location
    addressPrefixes: [
      vnetCidr
    ]
    subnets: [
      {
        name: 'spoke-snet-01'
        addressPrefix: cidrSubnet(vnetCidr, 24, 0)
        networkSecurityGroupId: defaultNsg.outputs.id
        routeTableId: defaultUDR.outputs.id
      }
      {
        name: 'spoke-snet-02'
        addressPrefix: cidrSubnet(vnetCidr, 24, 1)
        networkSecurityGroupId: defaultNsg.outputs.id
        routeTableId: defaultUDR.outputs.id
      }
    ]
  }
}

module peeringFromHub '../Modules/virtualNetworkPeerings.bicep' = {
  scope: hubRg
  params: {
    name: 'nic-hub-to-nic-spoke${number}-peering'
    parentVnetName: 'nic-hub-vnet'
    remoteVnetId: spokeVnet.outputs.id
    useRemoteGateways: false
    allowForwardedTraffic: false
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    doNotVerifyRemoteGateways: true
  }
}

module peeringToHub '../Modules/virtualNetworkPeerings.bicep' = {
  scope: spokeRg
  params: {
    name: 'nic-spoke${number}-to-hub-peering'
    parentVnetName: spokeVnet.outputs.name
    remoteVnetId: hubVnetId
    useRemoteGateways: false
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    doNotVerifyRemoteGateways: true
  }
}
