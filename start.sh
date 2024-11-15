#!/bin/bash

name="$1"

if [[ -z "$name" ]]; then
	echo "Usage: $0 <vm name>";
	exit 1;
fi

if [ ! -d "data/$name" ]; then
	echo "Data directory for $name (./data/$name/) does not exist. Run ./setup $name first"
	exit 1;
fi

# Find available port
while
  port=$(shuf -n 1 -i 49152-65535)
  netstat -atun | grep -q "$port"
do
  continue
done

echo "Starting VM $name at port $port"
echo "For remote shell, run: ssh user@localhost -p $port"

qemu-system-x86_64 \
	-m 2G \
	-smp 2 \
	-enable-kvm \
	-machine accel=kvm:tcg \
	-net nic -net user,hostfwd=tcp::"$port"-:22 \
	-drive if=virtio,format=qcow2,file="./data/$name/img.cow" \
	-drive media=cdrom,file="./data/$name/seed.iso"

