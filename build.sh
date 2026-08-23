#!/bin/bash

mkdir -vp ./mkosi.extra/usr/local/bin

download() {
	local url="$1"

	curl -f -L --output-dir /tmp/ -O "$url"
}

# Ethereum

GETH_FILE_NAME="geth-alltools-linux-amd64-1.17.4-36a7dc72.tar.gz"
GETH_URL="https://gethstore.blob.core.windows.net/builds/$GETH_FILE_NAME"

download "$GETH_URL"
tar -xvzf "/tmp/$GETH_FILE_NAME" -C ./mkosi.extra/usr/local/bin/

# Bitcoin

ELECTRUM_FILE_NAME="electrum-4.7.2-x86_64.AppImage"
ELECTRUM_URL="https://download.electrum.org/4.7.2/$ELECTRUM_FILE_NAME"

download "$ELECTRUM_URL"
cp -v "/tmp/$ELECTRUM_FILE_NAME" ./mkosi.extra/usr/local/bin
chmod +x ./mkosi.extra/usr/local/bin/$ELECTRUM_FILE_NAME
ln -vfs ./$ELECTRUM_FILE_NAME ./mkosi.extra/usr/local/bin/electrum

# Helper scripts

install -v ./balance.sh ./mkosi.extra/usr/local/bin/

# Service presets

mkdir -vp ./mkosi.extra/usr/lib/systemd/system-preset
cp -v ./systemd.preset ./mkosi.extra/usr/lib/systemd/system-preset/90-custom.preset

# mkosi

mkosi --force build
