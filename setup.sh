#!/bin/bash

name="$1"

if [[ -z "$name" ]]; then
	echo "Usage: $0 <vm name>";
	exit 1;
fi

if [ -d "data/$name" ]; then
	echo "VM data for $name already exists! (./data/$name/)"
	exit 1
fi

if [ ! -f ./data/oracular.img ]; then
	mkdir -p "data"
	echo "Downloading Ubuntu Oracular Image..."
 wget https://cloud-images.ubuntu.com/oracular/current/oracular-server-cloudimg-amd64.img \
		-O oracular.img.part
	mv oracular.img.part ./data/oracular.img
fi

# Create data directory for $name
mkdir -p "data/$name"

# Create metadata file for cloud-init
cat > "data/$name/meta-data" << EOF
instance-id: $name
local-hostname: $name
EOF

# Create cloud-init image
genisoimage -o "data/$name/seed.iso" \
	-V cidata \
	-r -J user-data "data/$name/meta-data"

# Create overlay image
qemu-img create \
	-o backing_file=../oracular.img,backing_fmt=qcow2 \
	-f qcow2 \
	"data/$name/img.cow" 10G

# Select random port
# Find available port (and hope it doesnt get used by others)
while
  port=$(shuf -n 1 -i 49152-65535)
  netstat -atun | grep -q "$port"
do
  continue
done

echo "$port" > ./data/$name/port

