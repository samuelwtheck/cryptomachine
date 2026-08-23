#!/bin/bash

this_script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo_stderr() {
	local message="$1"

	>&2 echo "$message"
}

exit_with_error() {
	local message="$1"

	echo_stderr "$message"
	exit 1
}

mkdir -vp $this_script_dir/mkosi.extra/usr/local/bin

download() {
	local url="$1"

	curl -f -L --output-dir /tmp/ -O "$url" \
		|| exit_with_error "curl failed with exit code $?"
}

# Ethereum

GETH_FILE_NAME="geth-alltools-linux-amd64-1.17.4-36a7dc72.tar.gz"
GETH_URL="https://gethstore.blob.core.windows.net/builds/$GETH_FILE_NAME"

download "$GETH_URL"

tar -xvzf "/tmp/$GETH_FILE_NAME" -C $this_script_dir/mkosi.extra/usr/local/bin/ \
	|| exit_with_error "tar failed with exit code $?"

# Bitcoin

ELECTRUM_FILE_NAME="electrum-4.7.2-x86_64.AppImage"
ELECTRUM_URL="https://download.electrum.org/4.7.2/$ELECTRUM_FILE_NAME"

download "$ELECTRUM_URL"

cp -v "/tmp/$ELECTRUM_FILE_NAME" $this_script_dir/mkosi.extra/usr/local/bin \
	|| exit_with_error "cp failed with exit code $?"

chmod +x $this_script_dir/mkosi.extra/usr/local/bin/$ELECTRUM_FILE_NAME \
	|| exit_with_error "chmod failed with exit code $?"

ln -vfs ./$ELECTRUM_FILE_NAME $this_script_dir/mkosi.extra/usr/local/bin/electrum \
	|| exit_with_error "ln failed with exit code $?"

# Helper scripts

install -v $this_script_dir/cryptoscripts/balance.sh $this_script_dir/mkosi.extra/usr/local/bin/ || exit_with_error "install failed with exit code $?"
install -v $this_script_dir/cryptoscripts/sign.sh    $this_script_dir/mkosi.extra/usr/local/bin/ || exit_with_error "install failed with exit code $?"

# Service presets

mkdir -vp this_script_dir/mkosi.extra/usr/lib/systemd/system-preset \
	|| exit_with_error "mkdir failed with exit code $?"

cp -v $this_script_dir/systemd.preset $this_script_dir/mkosi.extra/usr/lib/systemd/system-preset/90-custom.preset \
	|| exit_with_error "cp failed with exit code $?"

# mkosi

mkosi --force build \
	|| exit_with_error "mkosi failed with exit code $?"
