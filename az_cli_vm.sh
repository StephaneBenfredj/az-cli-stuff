# Variables
current_date=$(date +'%Y%m%d-%H%M')
rgName="stephaneb-rg"
location="francecentral"
owner="stephaneb"
vmName="stephaneb-ub22"
vnet="vnet-123"
subnet="sub-123"
size="Standard_D8s_v3"
# size="Standard_DS3_v2"
image="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
disk1Name="stephaneb-DiskUb22"
diskSize=128
diskStandard="StandardSSD_LRS"
sshKey="mykey.pub"

# Create a resource group
# az group create --name $rgName --location $location

# Create the first managed disk
az disk create \
    --name "$disk1Name-$current_date" \
    --resource-group $rgName \
    --location $location \
    --size-gb $diskSize \
    --sku $diskStandard

# Create a (spot) virtual machine with Ubuntu 22.04
az vm create \
    --name "$vmName-$current_date" \
    --resource-group $rgName \
    --location $location \
    --image $image \
    --admin-username ubuntu \
    --vnet-name $vnet \
    --subnet $subnet \
    --nic-delete-option delete \
    --attach-data-disks "$disk1Name-$current_date" \
    --os-disk-delete-option delete \
    --data-disk-delete-option "$disk1Name-$current_date=delete" \
    --nsg "" \
    --public-ip-sku Standard \
    --security-type Standard \
    --size $size \
    --priority Spot \
    --max-price -1 \
    --eviction-policy Deallocate \
    --ssh-key-value $sshKey \
    --custom-data my-cloud-init.yaml \
    --tags Owner=stephaneb Cleanup=False

# Add autoshutdown policy
az vm auto-shutdown -g $rgName -n "$vmName-$current_date" --time 2200 --email "youremail@zzzz.com"

# az vm disk attach \
#     --vm-name "$vmName-$current_date" \
#     --resource-group $rgName \
#     --name "$disk1Name-$current_date" \
#     --lun 3


# az vm create - does not allow to set lun apparently (or I missed it)
# --attach-data-disks "$disk1Name-$current_date" \
# need to use disk attach but problematic for cloud init sequencing


