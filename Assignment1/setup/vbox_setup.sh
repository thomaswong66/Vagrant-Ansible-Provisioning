#!/bin/bash

# This is a shortcut function that makes it shorter and more readable
vbmg () { VBoxManage.exe "$@"; }

# If you are using a Mac, you can just use
# vbmg () { VBoxManage "$@"; }

NET_NAME="4640"
VM_NAME="VM4640Test"
SSH_PORT="8022"
WEB_PORT="8000"
VM_FOLDER="D:\Virtual\VM4640Test"
ISO_FILE="D:\CentOS-7-x86_64-Minimal-1908.iso"


# This function will clean the NAT network and the virtual machine
clean_all () {
    vbmg natnetwork remove --netname "$NET_NAME"
    vbmg unregistervm "$VM_NAME" --delete
}

create_network () {
    vbmg natnetwork add --netname "$NET_NAME" --network "192.168.230.0/24" --dhcp off --ipv6 off --port-forward-4 "Rule_1:tcp:[127.0.0.1]:12022:[192.168.230.10]:22" \
    --port-forward-4 "Rule_2:tcp:[127.0.0.1]:12080:[192.168.230.10]:80"  
}

create_vm () {
    vbmg createvm --name "$VM_NAME" --ostype "RedHat_64" --register 
    vbmg modifyvm "$VM_NAME" --memory "1024" --cpus 1 --cableconnected2 on --nic2 natnetwork --audio none --nat-network2 "$NET_NAME"

    vbmg createmedium disk --filename "$VM_FOLDER".vdi --size 10240
    
    vbmg storagectl "$VM_NAME" --name "SATA Controller" --add sata 

    vbmg storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_FOLDER".vdi

    vbmg storagectl "$VM_NAME" --name "IDE Controller" --add ide 

    # not sure why we do not need to attach the iso when we manually did it? vbmg storageattach "$VM_NAME" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_FILE" 

    vbmg storageattach "$VM_NAME" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium emptydrive
} 

echo "Starting script..."

clean_all
create_network
create_vm

echo "DONE!"