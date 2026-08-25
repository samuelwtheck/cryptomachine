#!/bin/bash

this_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo_stderr() {
	local message="$1"

	>&2 echo "$message"
}

exit_with_error() {
	local message="$1"

	echo_stderr "error: $message"
	exit 1
}

mkdir -vp "$this_script_dir/mkosi.extra/usr/local/bin"

download() {
	local dir_url="$1"
	local file_name="$2"
	local expected_hash="$3"

	if [ -f "/var/tmp/$file_name" ]; then

		echo "$expected_hash  /var/tmp/$file_name" | sha256sum --check --status

		if [ $? -eq 0 ]; then

			echo_stderr "File already cached, and has the expected checksum, so skipping download: /var/tmp/$file_name"

			return

		fi

		echo_stderr "File already cached, but doesn't have the expected checksum, so ignoring it: /var/tmp/$file_name"

	fi

	local url="$dir_url/$file_name"

	curl -f -L --output-dir /var/tmp/ -O "$url" \
		|| exit_with_error "curl failed with exit code $?"

	echo "$expected_hash  /var/tmp/$file_name" | sha256sum --check --status \
		|| exit_with_error "Downloaded file checksum didn't match the expected one"

	echo_stderr "File successfully downloaded, having the expected checksum: /var/tmp/$file_name"
}

# Ethereum

geth_file_name="geth-alltools-linux-amd64-1.17.4-36a7dc72.tar.gz"
geth_dir_url="https://gethstore.blob.core.windows.net/builds"
geth_expected_checksum="7424a07bad62aa16482e2857b3021ced4840d31f5e59f62d588579ec568a138d"

download "$geth_dir_url" "$geth_file_name" "$geth_expected_checksum"

tar -xvzf "/var/tmp/$geth_file_name" -C $this_script_dir/mkosi.extra/usr/local/bin/ \
	|| exit_with_error "tar failed with exit code $?"

# Bitcoin

electrum_version="4.8.1"
electrum_file_name="electrum-$electrum_version-x86_64.AppImage"
electrum_dir_url="https://download.electrum.org/$electrum_version"
electrum_expected_checksum="bf97d9cf5d429fabfe70c3975e0e4137bdefb9bbaa80e7d0f4783281b3eb77e6"

download "$electrum_dir_url" "$electrum_file_name" "$electrum_expected_checksum"

cp -v "/var/tmp/$electrum_file_name" "$this_script_dir/mkosi.extra/usr/local/bin" \
	|| exit_with_error "cp failed with exit code $?"

chmod +x "$this_script_dir/mkosi.extra/usr/local/bin/$electrum_file_name" \
	|| exit_with_error "chmod failed with exit code $?"

ln -vfs "./$electrum_file_name" "$this_script_dir/mkosi.extra/usr/local/bin/electrum" \
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

mkdir -vp "$this_script_dir/mkosi.extra/usr/lib/systemd/system-preset" \
	|| exit_with_error "mkdir failed with exit code $?"

cp -v "$this_script_dir/systemd.preset" "$this_script_dir/mkosi.extra/usr/lib/systemd/system-preset/90-custom.preset" \
	|| exit_with_error "cp failed with exit code $?"

# mkosi

mkosi --force build \
	|| exit_with_error "mkosi failed with exit code $?"
