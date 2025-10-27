metadata name = 'Route Table (UDR)'
metadata description = 'This module deploys a Route Table (UDR).'
metadata owner = 'SimonWahlin'
metadata version = '0.0.2'

@description('The Route Table (UDR) Name.')
param name string

param routes route[] = []

@description('Disable BGP Propagation on route table.')
param disableBgpRoutePropagation bool = false

@description('Tags of the resource.')
param tags object = {}

@description('Location for all resources.')
param location string = resourceGroup().location

@export()
type route = {
  name: string
  properties: {
    addressPrefix: string
    nextHopType: ('Internet'|'VirtualAppliance'|'VirtualNetworkGateway'|'VnetLocal'|'None')
    nextHopIpAddress: string?
  }
}

resource routeTable 'Microsoft.Network/routeTables@2024-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    routes: routes
    disableBgpRoutePropagation: disableBgpRoutePropagation
  }
}

output id string = routeTable.id
output name string = routeTable.name
