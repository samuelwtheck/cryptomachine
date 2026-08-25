#!/bin/bash

this_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

for file in \
		mkosi.cache \
		mkosi.extra \
		image.raw \
		image.efi \
		image.initrd \
		image.vmlinuz \
		image \
		initrd.cpio.zst \
		initrd \
		; do
	rm -vrf "$this_script_dir/$file"
done