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
	local base_url="$1"
	local file_name="$2"
	local expected_hash="$3"

	if [ -f "/tmp/$file_name" ]; then

		echo "$expected_hash  /tmp/$file_name" | sha256sum --check --status

		if [ $? -eq 0 ]; then

			echo_stderr "File already cached, and has the expected checksum, so skipping download: /tmp/$file_name"

			return

		fi

		echo_stderr "File already cached, but doesn't have the expected checksum, so ignoring it: /tmp/$file_name"

	fi

	local url="$base_url/$file_name"

	curl -f -L --output-dir /tmp/ -O "$url" \
		|| exit_with_error "curl failed with exit code $?"

	echo "$expected_hash  /tmp/$file_name" | sha256sum --check --status \
		|| exit_with_error "Downloaded file checksum didn't match the expected one"

	echo_stderr "File successfully downloaded, having the expected checksum: /tmp/$file_name"
}

# Ethereum

GETH_FILE_NAME="geth-alltools-linux-amd64-1.17.4-36a7dc72.tar.gz"
GETH_BASE_URL="https://gethstore.blob.core.windows.net/builds"
GETH_EXPECTED_CHECKSUM="7424a07bad62aa16482e2857b3021ced4840d31f5e59f62d588579ec568a138d"

download "$GETH_BASE_URL" "$GETH_FILE_NAME" "$GETH_EXPECTED_CHECKSUM"

tar -xvzf "/tmp/$GETH_FILE_NAME" -C $this_script_dir/mkosi.extra/usr/local/bin/ \
	|| exit_with_error "tar failed with exit code $?"

# Bitcoin

ELECTRUM_VERSION="4.8.1"
ELECTRUM_FILE_NAME="electrum-$ELECTRUM_VERSION-x86_64.AppImage"
ELECTRUM_BASE_URL="https://download.electrum.org/$ELECTRUM_VERSION"
ELECTRUM_EXPECTED_CHECKSUM="bf97d9cf5d429fabfe70c3975e0e4137bdefb9bbaa80e7d0f4783281b3eb77e6"

download "$ELECTRUM_BASE_URL" "$ELECTRUM_FILE_NAME" "$ELECTRUM_EXPECTED_CHECKSUM"

cp -v "/tmp/$ELECTRUM_FILE_NAME" $this_script_dir/mkosi.extra/usr/local/bin \
	|| exit_with_error "cp failed with exit code $?"

chmod +x $this_script_dir/mkosi.extra/usr/local/bin/$ELECTRUM_FILE_NAME \
	|| exit_with_error "chmod failed with exit code $?"

ln -vfs ./$ELECTRUM_FILE_NAME $this_script_dir/mkosi.extra/usr/local/bin/electrum \
	|| exit_with_error "ln failed with exit code $?"

# Helper scripts

install_script() {
	local src_path="$1"
	local dest_file_name="$2"

	install -v "$this_script_dir/$src_path" "$this_script_dir/mkosi.extra/usr/local/bin/$dest_file_name" \
		|| exit_with_error "install failed with exit code $?"
}

install_script "cryptoscripts/btc/balance.sh" "btc-balance.sh"
install_script "cryptoscripts/btc/sign.sh"    "btc-sign.sh"
install_script "cryptoscripts/eth/balance.sh" "eth-balance.sh"
install_script "cryptoscripts/eth/sign.sh"    "eth-sign.sh"

# Service presets

mkdir -vp this_script_dir/mkosi.extra/usr/lib/systemd/system-preset \
	|| exit_with_error "mkdir failed with exit code $?"

cp -v $this_script_dir/systemd.preset $this_script_dir/mkosi.extra/usr/lib/systemd/system-preset/90-custom.preset \
	|| exit_with_error "cp failed with exit code $?"

# mkosi

mkosi --force build \
	|| exit_with_error "mkosi failed with exit code $?"
