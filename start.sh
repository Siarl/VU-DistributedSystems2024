#!/bin/bash

name="$1"

if [[ -z "$name" ]]; then
	echo "Usage: $0 <vm name>";
	exit 1;
fi

if [ ! -d "data/$name" ]; then
	echo "Data directory for $name (./data/$name/) does not exist. Running ./setup.sh $name first"
	./setup.sh $name
	echo "./setup.sh done"
fi

# Find available port
while
  port=$(shuf -n 1 -i 49152-65535)
  netstat -atun | grep -q "$port"
do
  continue
done

echo "ssh user@localhost -p $port -o StrictHostKeyChecking=no" > ./data/$name/ssh
chmod +x ./data/$name/ssh

echo "Starting VM $name at port $port"
echo "For remote shell, execute: ./data/$name/ssh"
echo "The VM will reboot once setup is complete!"

sleep 10;

qemu-system-x86_64 \
	-m 2G \
	-smp 1 \
	-enable-kvm \
	-machine accel=kvm:tcg \
	-nographic \
	-net nic -net user,hostfwd=tcp::"$port"-:22 \
	-drive if=virtio,format=qcow2,file="./data/$name/img.cow" \
	-drive media=cdrom,file="./data/$name/seed.iso"

