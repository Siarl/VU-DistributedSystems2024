#!/bin/bash

name="$1"

if [[ -z "$name" ]]; then
	echo "Usage: $0 <vm name>";
	echo "Options are:"
	find ./data/* -type d -exec basename {} \;
	exit 1;
fi

if [ ! -d "data/$name" ]; then
	echo "Data directory for $name (./data/$name/) does not exist. Run ./setup.sh first"
fi

# execute the ssh script generated by ./start.sh
./data/$name/ssh
