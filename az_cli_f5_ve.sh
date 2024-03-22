# f5 VE creation using CLI with mgmt, int interfaces + vs on int
# Note: make sure the pub key is in the same directory (absolute path was an issue iirc)

# Variables
current_date=$(date +'%Y%m%d-%H%M')
rgName="stephaneb-rg"
location="francecentral"
owner="stephaneb"
vmName="$owner-f5-25M-$current_date"
vnet="$owner-vnet"
size="Standard_DS3_v2"
image="f5-networks:f5-big-ip-good:f5-bigip-virtual-edition-25m-good-hourly:17.1.101000"
sshKey="key-01.pub"
subnet1="f5-mgmt"
subnet2="f5-int-nn"
nic1="$owner-f5-25M-mgmt-nic-$current_date"
nic2="$owner-f5-25M-int-nic-$current_date"

nic1Ip="10.0.1.11"
nic2Ip="10.0.4.11"

vs1="vs1-int-nic"
vs1Ip="10.0.4.221"

vs2="vs2-int-nic"
vs2Ip="10.0.4.222"


# Public IPs 
az network public-ip create --name $nic1-public-ip -g $rgName --allocation-method Static

# az network public-ip create --name $vs1-public-ip -g $rgName --allocation-method Static
# az network public-ip create --name $vs2-public-ip -g $rgName --allocation-method Static


# Need to create nics first
az network nic create --name $nic1 -g $rgName --vnet-name $vnet --subnet $subnet1 --ip-forwarding --private-ip-address $nic1Ip --public-ip-address $nic1-public-ip
az network nic create --name $nic2 -g $rgName --vnet-name $vnet --subnet $subnet2 --ip-forwarding --private-ip-address $nic2Ip

# Secondary IP for int nic for VS provisioning
az network nic ip-config create --name $vs1 -g $rgName --nic-name $nic2 --private-ip-address $vs1Ip
az network nic ip-config create --name $vs2 -g $rgName --nic-name $nic2 --private-ip-address $vs2Ip

# Assign public IP to VS
# az network nic ip-config update --name $vs1 --nic-name $nic2 -g $rgName --public-ip-address $vs1-public-ip
# az network nic ip-config update --name $vs2 --nic-name $nic2 -g $rgName --public-ip-address $vs2-public-ip


#create F5 instance
# need to confirm if spot is supported 

az vm create \
 --name $vmName \
 --resource-group $rgName \
 --location $location \
 --image $image  \
 --size $size \
 --os-disk-delete-option delete \
 --nics $nic1 $nic2 \
 --admin-username azureuser \
 --ssh-key-values $sshKey \
 --priority Spot \
 --max-price -1 \
 --eviction-policy Deallocate \
 --tags Owner=$owner Cleanup=False

# Add autoshutdown policy
az vm auto-shutdown -g $rgName -n $vmName --time 2200 --email "<user>@<domain>.com"




# % ssh admin@xxxx -i ~/.ssh/xxxxx.pem
# (...)

# admin@(localhost)(cfg-sync Standalone)(Active)(/Common)(tmos)# modify auth password admin
# changing password for admin
# new password:
# confirm password:

# admin@(localhost)(cfg-sync Standalone)(Active)(/Common)(tmos)# save sys config
# Saving running configuration...
#   /config/bigip.conf
#   /config/bigip_base.conf
#   /config/bigip_user.conf
# Saving Ethernet map ...done
# Saving PCI map ...
#  - verifying checksum .../var/run/f5pcimap: OK
# done
#  - saving ...done
# admin@(localhost)(cfg-sync Standalone)(Active)(/Common)(tmos)# quit

# F5 UI
# create VLAN
# name int
# 1.1 untagged
# 
# create selfip
# f5-int-nn-self
# ip address 10.0.4.11
# VLAN int
