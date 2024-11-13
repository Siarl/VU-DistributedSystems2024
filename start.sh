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

qemu-system-x86_64 \
	-m 2G \
	-smp 2 \
	-enable-kvm \
	-machine accel=kvm:tcg \
	-net nic -net user,hostfwd=tcp::2222-:22 \
	-drive if=virtio,format=qcow2,file="./data/$name/img.cow" \
	-drive media=cdrom,file="./data/$name/seed.iso"

