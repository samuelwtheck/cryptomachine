#!/bin/bash

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
	rm -vrf $file
done