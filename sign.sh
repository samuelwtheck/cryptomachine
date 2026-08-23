#!/bin/bash

# TODO:
# - Interactively ask for the seed phrase
# - Load wallet using provided seed phrase
# - Pass psbt file to be signed
# - Output the signature

#electrum --offline --mock-wallet-path --seed "your twelve or twenty four word seed phrase here" signtransaction "$(cat partially_signed.txn)" > signed.txn
