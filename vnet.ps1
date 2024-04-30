. .\variables.ps1



#create resource group configuration
$rg = @{
    Name = $rg_name
    Location = $location
}

#create resource group
New-AzResourceGroup @rg

#create virtual network configuration
$vnet = @{
    Name = $vnet_name
    ResourceGroupName = $rg_name
    AddressPrefix = $vnet_cidr
    Location = $location

}

#create virtual network
$virtualNetwork = New-AzVirtualNetwork @vnet


#create subnet configuration    

$subnet = @{
    name = $sub1_name
    AddressPrefix = $sub1_cidr
    virtualnetwork = $virtualNetwork
}


$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet


#associate the subnet to the virtual network created earlier

$virtualNetwork | Set-AzVirtualNetwork


#create bastion host subnet configuration

$subnet = @{
    name = $sub2_name
    AddressPrefix = $sub2_cidr
    virtualnetwork = $virtualNetwork
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet


#associate the subnet to the virtual network created earlier

$virtualNetwork | Set-AzVirtualNetwork

#create ip for bastion host

$ip = @{
    ResourceGroupName = $rg_name
    Name = $pubip_name
    Location = $location
    allocationmethod = "static"
    sku = "Standard"
    zone = 1
    
}
New-AzPublicIpAddress @ip


$bastion = @{
    name = $bastion_name
    ResourceGroupName = $rg_name
    publicipaddressname = $pubip_name
    publicipaddressrgname = $rg_name
    virtualnetworkrgname = $rg_name
    virtualnetworkname = $vnet_name
    sku = "Standard"

}

New-azbastion @bastion

$sshRule = @{
    Name = 'allow-ssh'
    Access = 'Allow'
    Protocol = 'Tcp'
    Direction = 'Inbound'
    Priority = 200
    SourceAddressPrefix = 'Internet'
    SourcePortRange = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange = '22'
}

$httpRule = @{
    Name = 'allow-http'
    Access = 'Allow'
    Protocol = 'Tcp'
    Direction = 'Inbound'
    Priority = 100
    SourceAddressPrefix = 'Internet'
    SourcePortRange = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange = '80'
}

#create ssh rule configuration
$sshRuleConfig = New-AzNetworkSecurityRuleConfig @sshRule
 
#create hhtp rule configuration
$httpRuleConfig = New-AzNetworkSecurityRuleConfig @httpRule

#create network security group
#associate the security rules created earlier

$NSG =@{
    Name ='FrontEnd'
    ResourceGroupName = $rg_name
    Location = $location
    SecurityRules = @($sshRuleConfig, $httpRuleConfig)
}

# Create NSG with multiple rules
$networkSecurityGroup = New-AzNetworkSecurityGroup @NSG

##create vm configuration, size and name

$vmconfig =@{
  VMName = $vmname
  VMSize = $vmSize
}

#Create NIC for vm

#create ip for vm



#create vm os linux
