#!/bin/bash

#NOTE: . ./init.sh
# Don't forget the first '.' to carry over to the next sh file.
# CTO is must always stay Admin. 

# This is the initialization setup. This setup all the emulator contracts such as NFT, FUSD, Profile.
# Also DAAM contracts daam_nft, auction. All Accounts are generated and assigned the following:
# DAAM Wallet to store NFTs
# AuctionWallet to store Auctions
# FUSD Wallet

# The Minter is also tested in this setup file. Accept/Decline

echo "========== Basic Setup: Flow Accounts, Contracts, & Funds =========="

echo "---------- Setup: Public Keys ----------"
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

export AGENT_PUBKEY=$(tail -1 ./keys/agent_keys         | awk '{print $3}' | tr -d '\n')
export AGENT2_PUBKEY=$(tail -1 ./keys/agent2_keys       | awk '{print $3}' | tr -d '\n')
export CREATOR2_PUBKEY=$(tail -1 ./keys/creator2_keys   | awk '{print $3}' | tr -d '\n')
export CLIENT2_PUBKEY=$(tail -1 ./keys/client2_keys     | awk '{print $3}' | tr -d '\n')

export FOUNDER1_PUBKEY=$(tail -1 ./keys/founder1_keys   | awk '{print $3}' | tr -d '\n')
export FOUNDER2_PUBKEY=$(tail -1 ./keys/founder2_keys   | awk '{print $3}' | tr -d '\n')
export FOUNDER3_PUBKEY=$(tail -1 ./keys/founder3_keys   | awk '{print $3}' | tr -d '\n')
export FOUNDER4_PUBKEY=$(tail -1 ./keys/founder4_keys   | awk '{print $3}' | tr -d '\n')
export FOUNDER5_PUBKEY=$(tail -1 ./keys/founder5_keys   | awk '{print $3}' | tr -d '\n')

export MFT_PUBKEY=$(tail -1 ./keys/mft_keys   | awk '{print $3}' | tr -d '\n')
export TOKENA_PUBKEY=$(tail -1 ./keys/tokenA_keys   | awk '{print $3}' | tr -d '\n')
export TOKENB_PUBKEY=$(tail -1 ./keys/tokenB_keys   | awk '{print $3}' | tr -d '\n')

echo "---------- Setup: Priavte Keys ----------"
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

export AGENT_PRIVKEY=$(tail -2 ./keys/agent_keys         | awk '{print $3}' | tr -d '\n')
export AGENT2_PRIVKEY=$(tail -2 ./keys/agent2_keys       | awk '{print $3}' | tr -d '\n')
export CREATOR2_PRIVKEY=$(tail -2 ./keys/creator2_keys   | awk '{print $3}' | tr -d '\n')
export CLIENT2_PRIVKEY=$(tail -2 ./keys/client2_keys     | awk '{print $3}' | tr -d '\n')

export MTF_PRIVKEY=$(tail -2 ./keys/mft_keys     | awk '{print $3}' | tr -d '\n')
export TOKENA_PRIVKEY=$(tail -2 ./keys/tokenA_keys     | awk '{print $3}' | tr -d '\n')
export TOKENB_PRIVKEY=$(tail -2 ./keys/tokenB_keys     | awk '{print $3}' | tr -d '\n')

# init accounts; Must be in order
echo "------------ Saving Account information ----------"
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

flow accounts create --key $AGENT_PUBKEY --save agent
flow accounts create --key $AGENT2_PUBKEY --save agent2
flow accounts create --key $CREATOR2_PUBKEY --save creator2
flow accounts create --key $CLIENT2_PUBKEY --save client2

flow accounts create --key $FOUNDER1_PUBKEY --save founder1
flow accounts create --key $FOUNDER2_PUBKEY --save founder2
flow accounts create --key $FOUNDER3_PUBKEY --save founder3
flow accounts create --key $FOUNDER4_PUBKEY --save founder4
flow accounts create --key $FOUNDER5_PUBKEY --save founder5

flow accounts create --key $MFT_PUBKEY --save mft
flow accounts create --key $TOKENA_PUBKEY --save tokenA
flow accounts create --key $TOKENB_PUBKEY --save tokenB

# Get & print Address
export CREATOR=$(head -1 creator | awk '{print $2}')
echo Creator: $CREATOR
export CREATOR2=$(head -1 creator2 | awk '{print $2}')
echo Creator2: $CREATOR2
export ADMIN=$(head -1 admin   | awk '{print $2}')
echo Admin:   $ADMIN
export ADMIN2=$(head -1 admin2 | awk '{print $2}')
echo Admin2: $ADMIN2
export AGENT=$(head -1 agent   | awk '{print $2}')
echo Agent:   $AGENT
export AGENT2=$(head -1 agent2 | awk '{print $2}')
echo Agent2: $AGENT2
export NOBODY=$(head -1 nobody | awk '{print $2}')
echo Nobody: $NOBODY
export CLIENT=$(head -1 client | awk '{print $2}')
echo Client: $CLIENT
export CLIENT2=$(head -1 client2 | awk '{print $2}')
echo Client2: $CLIENT2
export MARKETPLACE=$(head -1 marketplace     | awk '{print $2}')
echo Marketplace: $MARKETPLACE
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
export FOUNDER1=$(head -1 founder1 | awk '{print $2}')
echo FOUNDER1: $FOUNDER1
export FOUNDER2=$(head -1 founder2 | awk '{print $2}')
echo FOUNDER2: $FOUNDER2
export FOUNDER3=$(head -1 founder3 | awk '{print $2}')
echo FOUNDER3: $FOUNDER3
export FOUNDER4=$(head -1 founder4 | awk '{print $2}')
echo FOUNDER4: $FOUNDER4
export FOUNDER5=$(head -1 founder5 | awk '{print $2}')
echo FOUNDER5: $FOUNDER5

export MFT=$(head -1 mft | awk '{print $2}')
echo MTF: $MFT
export TOKENA=$(head -1 tokenA | awk '{print $2}')
echo TOKENA: $TOKENA
export TOKENB=$(head -1 tokenB | awk '{print $2}')
echo TOKENB: $TOKENB

echo "---------- Sending Flow for basic transactions -----------"
flow transactions send ./transactions/send_flow_em.cdc 200.0 $CREATOR
flow transactions send ./transactions/send_flow_em.cdc 200.0 $ADMIN
flow transactions send ./transactions/send_flow_em.cdc 200.0 $NOBODY
flow transactions send ./transactions/send_flow_em.cdc 200.0 $NFT
flow transactions send ./transactions/send_flow_em.cdc 200.0 $DAAM_NFT

flow transactions send ./transactions/send_flow_em.cdc 200.0 $MARKETPLACE
flow transactions send ./transactions/send_flow_em.cdc 200.0 $CLIENT
flow transactions send ./transactions/send_flow_em.cdc 200.0 $ADMIN2
flow transactions send ./transactions/send_flow_em.cdc 200.0 $PROFILE

flow transactions send ./transactions/send_flow_em.cdc 200.0 $CTO     # A.R

flow transactions send ./transactions/send_flow_em.cdc 200.0 $CREATOR2
flow transactions send ./transactions/send_flow_em.cdc 200.0 $CLIENT2
flow transactions send ./transactions/send_flow_em.cdc 200.0 $AGENT
flow transactions send ./transactions/send_flow_em.cdc 200.0 $AGENT2

flow transactions send ./transactions/send_flow_em.cdc 200.0 $FOUNDER1 # J.Y
flow transactions send ./transactions/send_flow_em.cdc 200.0 $FOUNDER2 # M.R
flow transactions send ./transactions/send_flow_em.cdc 200.0 $FOUNDER3 # G.P
flow transactions send ./transactions/send_flow_em.cdc 200.0 $FOUNDER4 # A.K
flow transactions send ./transactions/send_flow_em.cdc 200.0 $FOUNDER5 # M.H

flow transactions send ./transactions/send_flow_em.cdc 200.0 $MTF 
flow transactions send ./transactions/send_flow_em.cdc 200.0 $TOKENA
flow transactions send ./transactions/send_flow_em.cdc 200.0 $TOKENB

# Init Contracts

# FUSD Enulator Contract
echo "========== Publish Test FUSD Contract =========="
flow accounts add-contract FUSD ./contracts/FUSD.cdc --signer profile
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer cto
flow transactions send ./transactions/fusd/setup_fusd.cdc 100000000.0 $CTO --signer profile

echo "========== Publish Test TokenA Contract =========="
flow accounts add-contract TokenA ./contracts/TokenA.cdc --signer tokenA
flow transactions send ./transactions/tokenA/setup_fusd_vault.cdc --signer tokenA
flow transactions send ./transactions/tokenA/setup_fusd.cdc 100000000.0 $TOKENA --signer tokenA

echo "========== Publish Test TokenB Contract =========="
flow accounts add-contract TokenB ./contracts/TokenB.cdc --signer tokenB
flow transactions send ./transactions/tokenB/setup_fusd_vault.cdc --signer tokenB
flow transactions send ./transactions/tokenB/setup_fusd.cdc 100000000.0 $TOKENB --signer tokenB

echo "========== Send 100K FUSD to All Accounts =========="
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer agency
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer profile

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer creator
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer admin
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer nobody
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer daam_nft

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer marketplace
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer client
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer admin2
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer profile

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer agent
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer agent2
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer creator2
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer client2

flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer founder1
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer founder2
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer founder3
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer founder4
flow transactions send ./transactions/fusd/setup_fusd_vault.cdc --signer founder5

flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CREATOR --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $ADMIN --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $NOBODY --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $DAAM_NFT --signer cto

flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $MARKETPLACE --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CLIENT --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $ADMIN2 --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $PROFILE --signer cto

flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CREATOR2 --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $CLIENT2 --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $AGENT --signer cto
flow transactions send ./transactions/fusd/transfer_fusd.cdc 100000.0 $AGENT2 --signer cto

# Emulator Contracts
echo "========== Publish Supporting Contracts: NonFungibleToken & Profile"
flow accounts add-contract NonFungibleToken ./contracts/NonFungibleToken.cdc
flow accounts add-contract Profile ./contracts/Profile.cdc --signer profile
flow accounts add-contract MetadataViews ./contracts/MetadataViews.cdc

echo "========= Publish DAAM Contracts =========="
# Categories
flow accounts add-contract Categories ./contracts/categories.cdc --signer daam_nft
flow accounts add-contract MultiFungibleToken ./contracts/MultiFungibleToken.cdc --signer mft

flow transactions send ./transactions/send_flow_em.cdc --args-json \
'[{"type": "UFix64", "value": "11.0"}, {"type": "Address", "value": "0x0f7025fa05b578e3"}]'

# NFT
#export CODE=$(cat ../dev/hex_nft_enum)
#ARGUMENTS=$(echo "'{$CTO:0.19,$FOUNDER1:0.23,$FOUNDER2:0.11,$FOUNDER3:0.11,$FOUNDER4:0.19,$FOUNDER5:0.17}' '[$CTO,$FOUNDER1,$FOUNDER2,$FOUNDER3,$FOUNDER4,$FOUNDER5]'")
#COMMAND='flow transactions send ./transactions/init_DAAM_Agency.cdc "DAAM" $CODE '$ARGUMENTS' --signer daam_nft'
#eval $COMMAND
flow transactions send ./transactions/init_DAAM_Agency.cdc --signer daam_nft
flow accounts update-contract DAAM ./contracts/daam_nft.cdc --signer daam_nft

#Auction
flow accounts add-contract AuctionHouse ./contracts/auction.cdc --signer marketplace

echo "========== SETUP ALL TYPES OF ACCOUNTS: DAAM, Profile, AuctionWallet  ==========" 

# Setup Profiles
echo "========= Setup All Profiles ========="
flow transactions send ./transactions/create_profile.cdc --signer cto
flow transactions send ./transactions/create_profile.cdc --signer admin
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer agent
flow transactions send ./transactions/create_profile.cdc --signer agent2

flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer creator2
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer client2
flow transactions send ./transactions/create_profile.cdc --signer nobody

flow transactions send ./transactions/create_profile.cdc --signer founder1
flow transactions send ./transactions/create_profile.cdc --signer founder2
flow transactions send ./transactions/create_profile.cdc --signer founder3
flow transactions send ./transactions/create_profile.cdc --signer founder4
flow transactions send ./transactions/create_profile.cdc --signer founder5

# Setup DAAM Accounts
echo "========= Setup All DAAM Accounts ========="
# Non-Public Accounts
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer cto
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer admin
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer admin2
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer founder1
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer founder2
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer founder3
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer founder4
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc false --signer founder5

flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer agent
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer agent2
# Public Accounts
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer creator
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer creator2
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer client
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer client2
flow transactions send ./transactions/daam_wallet/setup_daam_account.cdc true --signer nobody

# Setup Auction Wallets
echo "========= Setup All Auction Wallets ========="
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer cto
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin2
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer agent
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer agent2

flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator2
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client2
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer nobody

# Answer Default Admin / CTO
echo "Answer default Admin Invite created by contract creation. CTO"
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer cto
echo "Answer default Admin Invite created by contract creation. Founders"
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer founder1
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer founder2
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer founder3
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer founder4
flow transactions send ./transactions/answer/answer_admin_invite.cdc true --signer founder5 

# Setup AuctionHouse Minter Key
echo "Verify Minter Status: nil"
flow scripts execute ./scripts/is_minter.cdc $MARKETPLACE

echo "Send AuctionHouse Minter Key."
flow transactions send ./transactions/admin/invite_minter.cdc $MARKETPLACE --signer cto

echo "AuctionHouse Declines Minter Key."
flow transactions send ./transactions/answer/answer_minter_invite.cdc false --signer marketplace

echo "Verify Minter Status: false"
flow scripts execute ./scripts/is_minter.cdc $MARKETPLACE

echo "Re-Send AuctionHouse Minter Key."
flow transactions send ./transactions/admin/invite_minter.cdc $MARKETPLACE --signer cto

echo "AuctionHouse Accepted Minter Key."
flow transactions send ./transactions/answer/answer_minter_invite.cdc true --signer marketplace

echo "Verify Minter Status: true"
flow scripts execute ./scripts/is_minter.cdc $MARKETPLACE

echo "----------- All Contracts Are Published with Flow Accounts FUSD Funded. -----------"

# pre_nft variables
export REMOVED_METADATA
export DISAPPROVED_METADTA
export DISAPPROVED_COPYRIGHT
