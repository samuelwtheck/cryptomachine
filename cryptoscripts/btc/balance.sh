#!/bin/bash

echo_stderr() {
	local message="$1"

	>&2 echo "$message"
}

exit_with_error() {
	local message="$1"

	echo_stderr "error: $message"
	exit 1
}

test "$#" -eq 1 || exit_with_error "Wrong number of arguments. Expected one (your bitcoin wallet's master public key), got $#"

pubkey="$1"

wallets_dir="/root/.electrum/wallets"

mkdir -vp "$wallets_dir" \
	|| exit_with_error "mkdir returned non-zero exit code $?"

electrum --offline restore "$pubkey" -w "$wallets_dir/watch_only_wallet" \
	|| exit_with_error "electrum returned non-zero exit code $?"

electrum daemon -d \
	|| exit_with_error "electrum returned non-zero exit code $?"

electrum load_wallet -w "$wallets_dir/watch_only_wallet" \
	|| exit_with_error "electrum returned non-zero exit code $?"

# TODO: Handle subshell errors
BTC_BALANCE=$(electrum getbalance -w "$wallets_dir/watch_only_wallet" | jq -r '.confirmed')

electrum setconfig use_exchange_rate true \
	|| exit_with_error "electrum returned non-zero exit code $?"

electrum convert_currency --from_amount "$BTC_BALANCE" --from_ccy BTC --to_ccy EUR \
	|| exit_with_error "electrum returned non-zero exit code $?"
