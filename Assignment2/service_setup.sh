#!/bin/bash
vbmg () { VBoxManage.exe "$@"; }

./vbox_setup.sh

start_pxe () {
    vbmg startvm "PXE4640"
    while /bin/true; do
        ssh -i acit_admin_id_rsa -p 12222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q pxe exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 2
        else
                break
        fi
done

echo "PXE STARTED, READY TO COPYYYYY"
}

copy_files() {
	echo "Transferring files...................................................."


	ssh -i acit_admin_id_rsa -P 12222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q pxe "sudo chmod 755 /var/www/lighttpd/; \
            sudo chown admin /var/www/lighttpd/files; \
            sudo chmod 755 /var/www/lighttpd/files; \
            sudo chown admin /var/www/lighttpd/files/ks.cfg"
    scp ks.cfg pxe:/var/www/lighttpd/files
    scp -r acit4640 pxe:/var/www/lighttpd/files

    ssh -i acit_admin_id_rsa -P 12222 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q pxe "sudo chmod 755 /var/www/lighttpd/files/ks.cfg;\
            sudo chmod -R 777 /var/www/lighttpd/files/acit4640"


    echo "-.-.-.-.-.-.-.-.-.-.-.-.-.-.-Files Copied!-.-.-.-.-.-.-.-.-.-.-.-.-.-.-"
}

boot_new_vm (){
	    vbmg startvm "VM4640Test"
	     while /bin/true; do
        ssh -i acit_admin_id_rsa -p 12022 \
            -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
            -q todoapp exit
        if [ $? -ne 0 ]; then
                echo "Installing OS...This may take a while....."
                sleep 20
        else
            vbmg controlvm "PXE4640" acpipowerbutton
                break
        fi
done
}

start_pxe
copy_files
boot_new_vm