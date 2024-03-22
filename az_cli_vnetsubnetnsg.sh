# Variables
current_date=$(date +'%Y%m%d-%H%M')
owner="stephaneb"
location="francecentral"
rgName="$owner-rg"
vmName="$owner-ub22"

#vvnet and subnets
vnetName="$owner-FR-f5-vnet"
vnetPrefix1="10.33.0.0/16"
subnet0="$owner-mgmt"
subnet1="$owner-ext"
subnet2="$owner-int"
subnet0Prefix="10.99.0.0/24"
subnet1Prefix="10.99.1.0/24"
subnet2Prefix="10.99.2.0/24"

# NSG
nsgName="management-nsg"
myIpPrefix="86.238.100.137/32"


# Provision vnet
az network vnet create --name $vnetName -g $rgName -l $location --address-prefixes $vnetPrefix1

# Provision subnets in the vnet
az network vnet subnet create --name management -g $rgName --vnet-name $vnetName  --address-prefixes 10.99.0.0/24
az network vnet subnet create --name external -g $rgName --vnet-name $vnetName --address-prefixes 10.99.1.0/24
az network vnet subnet create --name internal -g $rgName --vnet-name $vnetName --address-prefixes 10.99.2.0/24


# Network Security Group (Note: applies at RG level - can be re-used across vnets in same RG)
az network nsg create --name management-nsg -g $rgName -l $location
az network nsg rule create --name allow_22  -g $rgName --nsg-name $nsgName --priority 101 --access Allow --description 'allow port 22' --destination-port-ranges 22 --protocol Tcp --source-address-prefixes $myIpPrefix
az network nsg rule create --name allow_443 -g $rgName --nsg-name $nsgName --priority 102 --access Allow --description 'allow port 443' --destination-port-ranges 443 --protocol Tcp --source-address-prefixes $myIpPrefix
