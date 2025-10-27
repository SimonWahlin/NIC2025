metadata name = 'Virtual Network'
metadata description = 'This module deploys a Virtual Network (vNet) peering.'
metadata owner = 'SimonWahlin'
metadata version = '0.0.2'

@description('Name of the peering.')
param name string

@description('Name of the parent virtual network.')
param parentVnetName string

@description('List of local subnet names to which the peering applies.')
param localSubnetNames string[] = []

@description('ResourceId for remote virtual network.')
param remoteVnetId string

@description('List of remote subnet names to which the peering applies.')
param remoteSubnetNames string[] = []

@description('Allow traffic that is forwarded through the remote network into the local network.')
param allowForwardedTraffic bool = true

@description('Allow remote network to use gateways in the local network.')
param allowGatewayTransit bool = false

@description('If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. ')
param useRemoteGateways bool = true

@description('Dont verify the provisioning state of the remote gateway.')
param doNotVerifyRemoteGateways bool = false

@description('Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space.')
param allowVirtualNetworkAccess bool = true

#disable-next-line no-unused-vars //this is an assertion
var assertSubnetPeering = (empty(localSubnetNames) && !empty(remoteSubnetNames)) || (!empty(localSubnetNames) && empty(remoteSubnetNames)) ? fail('You must provide either both localSubnetNames and remoteSubnetNames or neither of them.') : true

resource parentVnet 'Microsoft.Network/virtualNetworks@2024-10-01' existing = {
  name: parentVnetName
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-10-01' = {
  name: name
  parent: parentVnet
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    doNotVerifyRemoteGateways: doNotVerifyRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    localSubnetNames: empty(localSubnetNames) ? null : localSubnetNames
    remoteSubnetNames: empty(remoteSubnetNames) ? null : remoteSubnetNames
    peerCompleteVnets: empty(localSubnetNames) ? null : false
    useRemoteGateways: useRemoteGateways
  }
}

output id string = peering.id
output name string = peering.name
output remoteVnetId string = peering.properties.remoteVirtualNetwork.id
