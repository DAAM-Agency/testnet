#!/bin/bash

export ARTIST_PUBKEY=0x$(tail -1 ./keys/artist_keys     | awk '{print $3}' | tr -d '\n')
export ADMIN_PUBKEY=$(tail -1 ./keys/admin_keys         | awk '{print $3}' | tr -d '\n')
export CLIENT_PUBKEY=$(tail -1 ./keys/client_keys       | awk '{print $3}' | tr -d '\n')
export MARKETPLACE_PUBKEY=$(tail -1 ./keys/marketplace_keys | awk '{print $3}' | tr -d '\n')
export NFT_PUBKEY=$(tail -1 ./keys/nft_keys             | awk '{print $3}' | tr -d '\n')
export PROFILE_PUBKEY=$(tail -1 ./keys/profile_keys     | awk '{print $3}' | tr -d '\n')
export NOBODY_PUBKEY=$(tail -1 ./keys/nobody_keys       | awk '{print $3}' | tr -d '\n')
export COPYRIGHT_PUBKEY=$(tail -1 ./keys/copyright_keys | awk '{print $3}' | tr -d '\n')
export DAAM_NFT_PUBKEY=$(tail -1 ./keys/daam_nft_keys   | awk '{print $3}' | tr -d '\n')

export ARTIST_PRIVKEY=$(tail -2 ./keys/artist_keys       | awk '{print $3}' | tr -d '\n')
export ADMIN_PRIVKEY=$(tail -2 ./keys/admin_keys         | awk '{print $3}' | tr -d '\n')
export CLIENT_PRIVKEY=$(tail -2 ./keys/client_keys       | awk '{print $3}' | tr -d '\n')
export MARKETPLACE_PRIVKEY=$(tail -2 ./keys/marketplace_keys | awk '{print $3}' | tr -d '\n')
export NFT_PRIVKEY=$(tail -2 ./keys/nft_keys             | awk '{print $3}' | tr -d '\n')
export PROFILE_PRIVKEY=$(tail -2 ./keys/profile_keys     | awk '{print $3}' | tr -d '\n')
export NOBODY_PRIVKEY=$(tail -2 ./keys/nobody_keys       | awk '{print $3}' | tr -d '\n')
export COPYRIGHT_PRIVKEY=$(tail -2 ./keys/copyright_keys | awk '{print $3}' | tr -d '\n')
export DAAM_NFT_PRIVKEY=$(tail -2 ./keys/daam_nft_keys   | awk '{print $3}' | tr -d '\n')

# init accounts; Must be in order
flow accounts create --key $ADMIN_PUBKEY --save admin
flow accounts create --key $ARTIST_PUBKEY --save artist
flow accounts create --key $CLIENT_PUBKEY --save client
flow accounts create --key $COPYRIGHT_PUBKEY --save copyright
flow accounts create --key $MARKETPLACE_PUBKEY --save marketplace
flow accounts create --key $NFT_PUBKEY --save nft
flow accounts create --key $NOBODY_PUBKEY --save nobody
flow accounts create --key $PROFILE_PUBKEY --save profile
flow accounts create --key $DAAM_NFT_PUBKEY --save daam_nft

# Get & print Address
export ARTIST=$(head -1 artist | awk '{print $2}')
echo Artist: $ARTIST
export ADMIN=$(head -1 admin   | awk '{print $2}')
echo Admin:   $ADMIN
export NOBODY=$(head -1 nobody | awk '{print $2}')
echo Nobody: $NOBODY
export CLIENT=$(head -1 client | awk '{print $2}')
echo Client: $CLIENT
export MARKETPLACE=$(head -1 marketplace     | awk '{print $2}')
echo MARKETPLACE: $MARKETPLACE
export COPYRIGHT=$(head -1 copyright | awk '{print $2}')
echo Copyright: $COPYRIGHT
export NFT=$(head -1 nft        | awk '{print $2}')
echo NFT: $NFT
export PROFILE=$(head -1 profile | awk '{print $2}')
echo Profile: $PROFILE
export DAAM_NFT=$(head -1 daam_nft | awk '{print $2}')
echo DAAM_NFT: $DAAM_NFT

flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$ARTIST
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$ADMIN
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$NOBODY
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$NFT
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$DAAM_NFT

flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$MARKETPLACE
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$CLIENT
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$COPYRIGHT
flow transactions send ./testnet/transactions/send_flow_em.cdc --arg UFix64:10.0 --arg Address:$PROFILE

# init contracts
flow accounts add-contract NonFungibleToken ./testnet/contracts/NonFungibleToken.cdc --signer nft
flow accounts add-contract Profile ./testnet/contracts/Profile.cdc --signer profile
flow accounts add-contract DAAMCopyright ./testnet/contracts/daamCopyright.cdc --signer copyright
flow accounts add-contract DAAM ./testnet/contracts/daam_nft.cdc --signer daam_nft
flow accounts add-contract Marketplace ./testnet/contracts/marketplace2.cdc --signer marketplace
