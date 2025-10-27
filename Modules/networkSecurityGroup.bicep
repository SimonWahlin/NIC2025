metadata name = 'Network Security Group'
metadata description = 'This module deploys a Network Security Group (NSG).'
metadata owner = 'SimonWahlin'
metadata version = '0.0.1'

@description('Name of the NSG.')
param name string

@description('List of security rules for the NSG.')
param rules nsgRule[] = []

@description('Tags of the resource.')
param tags object = {}

@description('Location to for the resources.')
param location string = resourceGroup().location

@export()
type nsgRule = {
  name: string
  properties: {
    @minValue(100)
    @maxValue(4096)
    priority: int
    description: string?
    access: ('Allow' | 'Deny')
    direction: ('Inbound' | 'Outbound')
    sourceAddressPrefix: string?
    sourceAddressPrefixes: string[]?
    sourcePortRange: string?
    sourcePortRanges: string[]?
    destinationAddressPrefix: string?
    destinationAddressPrefixes: string[]?
    destinationPortRange: string?
    destinationPortRanges: string[]?
    protocol: ('*'|'Ah'|'Esp'|'Icmp'|'Tcp'|'Udp')
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    // securityRules: rules
  }
  resource nsgRules 'securityRules@2024-10-01' = [for rule in rules: {
    name: rule.name
    properties: rule.properties
  }]
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
