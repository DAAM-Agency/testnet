#!/bin/bash

export CREATOR_PUBKEY=0x$(tail -1 ./keys/creator_keys   | awk '{print $3}' | tr -d '\n')
export ADMIN_PUBKEY=$(tail -1 ./keys/admin_keys         | awk '{print $3}' | tr -d '\n')
export CLIENT_PUBKEY=$(tail -1 ./keys/client_keys       | awk '{print $3}' | tr -d '\n')
export MARKETPLACE_PUBKEY=$(tail -1 ./keys/marketplace_keys | awk '{print $3}' | tr -d '\n')
export NFT_PUBKEY=$(tail -1 ./keys/nft_keys             | awk '{print $3}' | tr -d '\n')
export PROFILE_PUBKEY=$(tail -1 ./keys/profile_keys     | awk '{print $3}' | tr -d '\n')
export NOBODY_PUBKEY=$(tail -1 ./keys/nobody_keys       | awk '{print $3}' | tr -d '\n')
export ADMIN2_PUBKEY=$(tail -1 ./keys/admin2_keys       | awk '{print $3}' | tr -d '\n')
export DAAM_NFT_PUBKEY=$(tail -1 ./keys/daam_nft_keys   | awk '{print $3}' | tr -d '\n')
export AGENCY_PUBKEY=$(tail -1 ./keys/agency_keys       | awk '{print $3}' | tr -d '\n')
export CTO_PUBKEY=$(tail -1 ./keys/cto_keys             | awk '{print $3}' | tr -d '\n')

export CREATOR_PRIVKEY=$(tail -2 ./keys/creator_keys     | awk '{print $3}' | tr -d '\n')
export ADMIN_PRIVKEY=$(tail -2 ./keys/admin_keys         | awk '{print $3}' | tr -d '\n')
export CLIENT_PRIVKEY=$(tail -2 ./keys/client_keys       | awk '{print $3}' | tr -d '\n')
export MARKETPLACE_PRIVKEY=$(tail -2 ./keys/marketplace_keys | awk '{print $3}' | tr -d '\n')
export NFT_PRIVKEY=$(tail -2 ./keys/nft_keys             | awk '{print $3}' | tr -d '\n')
export PROFILE_PRIVKEY=$(tail -2 ./keys/profile_keys     | awk '{print $3}' | tr -d '\n')
export NOBODY_PRIVKEY=$(tail -2 ./keys/nobody_keys       | awk '{print $3}' | tr -d '\n')
export ADMIN2_PRIVKEY=$(tail -2 ./keys/admin2_keys       | awk '{print $3}' | tr -d '\n')
export DAAM_NFT_PRIVKEY=$(tail -2 ./keys/daam_nft_keys   | awk '{print $3}' | tr -d '\n')
export AGENCY_PRIVKEY=$(tail -2 ./keys/agency_keys       | awk '{print $3}' | tr -d '\n')
export CTO_PRIVKEY=$(tail -2 ./keys/cto_keys             | awk '{print $3}' | tr -d '\n')

# init accounts; Must be in order
flow accounts create --key $ADMIN_PUBKEY --save admin
flow accounts create --key $CREATOR_PUBKEY --save creator
flow accounts create --key $CLIENT_PUBKEY --save client
flow accounts create --key $ADMIN2_PUBKEY --save admin2
flow accounts create --key $MARKETPLACE_PUBKEY --save marketplace
flow accounts create --key $NFT_PUBKEY --save nft
flow accounts create --key $NOBODY_PUBKEY --save nobody
flow accounts create --key $PROFILE_PUBKEY --save profile
flow accounts create --key $DAAM_NFT_PUBKEY --save daam_nft
flow accounts create --key $AGENCY_PUBKEY --save agency
flow accounts create --key $CTO_PUBKEY --save cto

# Get & print Address
export CREATOR=$(head -1 creator | awk '{print $2}')
echo Creator: $CREATOR
export ADMIN=$(head -1 admin   | awk '{print $2}')
echo Admin:   $ADMIN
export NOBODY=$(head -1 nobody | awk '{print $2}')
echo Nobody: $NOBODY
export CLIENT=$(head -1 client | awk '{print $2}')
echo Client: $CLIENT
export MARKETPLACE=$(head -1 marketplace     | awk '{print $2}')
echo Marketplace: $MARKETPLACE
export ADMIN2=$(head -1 admin2 | awk '{print $2}')
echo Copyright: $ADMIN2
export NFT=$(head -1 nft        | awk '{print $2}')
echo NFT: $NFT
export PROFILE=$(head -1 profile | awk '{print $2}')
echo Profile: $PROFILE
export DAAM_NFT=$(head -1 daam_nft | awk '{print $2}')
echo DAAM NFT: $DAAM_NFT
export AGENCY=$(head -1 agency | awk '{print $2}')
echo Agency: $AGENCY
export CTO=$(head -1 cto | awk '{print $2}')
echo CTO: $CTO

flow transactions send ./transactions/send_flow_em.cdc 199.999 $CREATOR
flow transactions send ./transactions/send_flow_em.cdc 199.999 $ADMIN
flow transactions send ./transactions/send_flow_em.cdc 199.999 $NOBODY
flow transactions send ./transactions/send_flow_em.cdc 199.999 $NFT
flow transactions send ./transactions/send_flow_em.cdc 199.999 $DAAM_NFT

flow transactions send ./transactions/send_flow_em.cdc 199.999 $MARKETPLACE
flow transactions send ./transactions/send_flow_em.cdc 199.999 $CLIENT
flow transactions send ./transactions/send_flow_em.cdc 199.999 $ADMIN2
flow transactions send ./transactions/send_flow_em.cdc 199.999 $PROFILE

flow transactions send ./transactions/send_flow_em.cdc 199.999 $CTO

# Init Contracts

# FUSD Enulator Contract
flow accounts add-contract FUSD ./contracts/FUSD.cdc --signer profile
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer cto
flow transactions send ./transactions/setup_fusd.cdc 1000000.0 $CTO --signer profile

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer agency

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer creator
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer admin
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer nobody
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer daam_nft

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer marketplace
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer client
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer admin2
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer profile

flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CREATOR --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $ADMIN --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $NOBODY --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $DAAM_NFT --signer cto

flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $MARKETPLACE --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CLIENT --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $ADMIN2 --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $PROFILE --signer cto

# Emulator Contracts
flow accounts add-contract NonFungibleToken ./contracts/NonFungibleToken.cdc
flow accounts add-contract Profile ./contracts/Profile.cdc --signer profile

# NFT
export CODE=$(cat ../dev/hex_nft_enum)
flow transactions send ../testnet_keys/init_DAAM_Agency.cdc "DAAM" $CODE $AGENCY $CTO --signer daam_nft
flow accounts update-contract DAAM ./contracts/daam_nft.cdc --signer daam_nft

#Auction
flow accounts add-contract AuctionHouse ./contracts/auction.cdc --signer marketplace

# Invite Admin/CTO
flow transactions send ./transactions/create_profile.cdc --signer cto
flow transactions send ./transactions/answer_admin_invite.cdc true --signer cto

# Invite Admin
flow transactions send ./transactions/create_profile.cdc --signer admin
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN --signer cto
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin

# Setup Marketplace
flow transactions send ./transactions/admin/invite_minter.cdc $MARKETPLACE --signer admin
flow transactions send ./transactions/answer_minter_invite.cdc true --signer marketplace
