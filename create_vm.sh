#!/bin/sh
#
# Use this script to generate a VM in the EGI Federated cloud
#
#
# Run create_vm and create_storage first (comment the other functions)
# and then set VM_ID and STORAGE_ID
# 

main(){
    ENDPOINT=https://PLEASE_CHANGE:ME/
    VM_ID=CHANGE_ME # Set once a VM was created
    STORAGE_ID=CHANGE_ME # Set once a storage was created
    # create_vm
    # create_storage
    # link_storage_to_vm
    # extract_ip_of_vm
}

create_vm(){
    	occi \
    	--endpoint $ENDPOINT \
    	--action create \
    	--resource compute \
    	--mixin os_tpl#uuid_gwdg_ubuntu_14_04_lts_56 \
    	--mixin resource_tpl#large \
    	--attribute occi.core.title="READemption_demo" \
    	--voms \
    	--auth x509 \
    	--user-cred /tmp/x509up_u1000
}

create_storage(){
    occi \
	--endpoint $ENDPOINT \
	--action create \
	--resource storage \
	--attribute occi.core.title="Storage_for_demo" \
	--attribute occi.storage.size="num(20)" \
	--voms \
	--auth x509 \
	--user-cred /tmp/x509up_u1000
}

link_storage_to_vm(){
    occi \
	--endpoint $ENDPOINT \
	--action link \
	--link /storage/$STORAGE_ID \
	--resource /compute/$VM_ID \
	--attribute occi.storagelink.deviceid="/dev/vdb" \
	--auth x509 \
	--user-cred /tmp/x509up_u1000 \
	--voms
}

extract_ip_of_vm(){
    occi \
	--endpoint $ENDPOINT \
	--action describe \
	--resource /compute/$VM_ID \
	--auth x509 \
	--user-cred /tmp/x509up_u1000 \
	--voms \
	| grep occi.networkinterface.address
}

main
