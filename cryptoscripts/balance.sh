#!/bin/bash

pubkey="$1"

mkdir -vp /root/.electrum/wallets

electrum --offline restore "$pubkey" -w ~/.electrum/wallets/watch_only_wallet
electrum daemon -d
electrum load_wallet -w ~/.electrum/wallets/watch_only_wallet

BTC_BALANCE=$(electrum getbalance -w ~/.electrum/wallets/watch_only_wallet | jq -r '.confirmed')

electrum setconfig use_exchange_rate true

electrum convert_currency --from_amount $BTC_BALANCE --from_ccy BTC --to_ccy EUR
