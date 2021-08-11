# verify transactions

# Setup Profiles
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer nobody

# Setup DAAM Accounts
flow transactions send ./transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./transactions/setup_daam_account.cdc --signer creator
flow transactions send ./transactions/setup_daam_account.cdc --signer client
flow transactions send ./transactions/setup_daam_account.cdc --signer admin2

# Setup Auction Wallets
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer nobody
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin2

# Invite Creator & Accept
flow transactions send ./transactions/admin/invite_creator.cdc --arg Address:$CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc --arg Bool:true --signer creator

# Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc --arg Bool:true --signer admin2

# Submit 2 Metadata: #1 Solo, #2 Series(of 2)
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:1 --arg String:"data A" --arg String:"thumbnail A" --arg String:"file A" --signer creator
flow transactions send ./transactions/metadata/metadata.cdc --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:7 --arg String:"data B" --arg String:"thumbnail B" --arg String:"file B" --signer creator
flow transactions send ./transactions/metadata/metadata.cdc --signer creator

# Approve the Metadatas
flow transactions send ./transactions/admin/change_metadata_status.cdc --arg UInt64:1 --arg Bool:true --signer admin
flow transactions send ./transactions/admin/change_metadata_status.cdc --arg UInt64:2 --arg Bool:true --signer admin2

# Request Royality
flow transactions send ./transactions/request/create_request.cdc --args-json '[{"type": "UInt64", "value": "2"}, {"type": "Dictionary", "value": [{"key": {"type": "Address", "value": "0xeb179c27144f783c"}, "value": {"type": "UFix64", "value": "0.05"}}, {"key": {"type": "Address", "value": "0x179b6b1cb6755e31"}, "value": {"type": "UFix64", "value": "0.16"}}] }]' --signer creator
'''
flow transactions send ./transactions/admin/bargin_admin.cdc --arg UInt64:2 --arg UFix64:0.155 --signer admin
flow transactions send ./transactions/creator/bargin_creator.cdc --arg UInt64:2 UFix64:0.16 --signer creator
flow transactions send ./transactions/admin/bargin_admin.cdc --arg UInt64:2 --arg UFix64:0.16 --signer admin

flow transactions send ./transactions/request/accept_default.cdc --arg UInt64:1 --signer creator
#flow transactions send ./transactions/request/make_request.cdc --arg UInt64:1 --signer creator
#flow transactions send ./transactions/admin/answer_request.cdc --arg UInt64:1 --arg Bool:true --signer admin

# Change Copyright
flow transactions send ./transactions/admin/change_copyright.cdc --arg UInt64:1 --arg Int:3 --signer admin
flow transactions send ./transactions/admin/change_copyright.cdc --arg UInt64:2 --arg Int:3 --signer admin

# Change Creator Status
flow transactions send ./transactions/admin/change_creator_status.cdc --arg Address:$CREATOR --arg Bool:false --signer admin2

# Remove Admin / Creator
flow transactions send ./transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin2
flow transactions send ./transactions/admin/remove_creator.cdc --arg Address:$CREATOR --signer admin

# (Re)Invite Creator & Accept
flow transactions send ./transactions/creator/reset_creator.cdc --signer creator
flow transactions send ./transactions/admin/reset_admin.cdc --signer admin2

flow transactions send ./transactions/admin/invite_creator.cdc --arg Address:$CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc --arg Bool:true --signer creator

# (Re)Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc --arg Bool:true --signer admin2

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

# tokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool
flow transactions send ./transactions/auction/create_original_auction.cdc --arg UInt64:1 --arg UFix64:$START \
--arg UFix64:100.0 --arg Bool:false --arg UFix64:60.0 --arg Bool:false --arg UFix64:0.05 --arg UFix64:10.00 \
--arg UFix64:25.0 --arg UFix64:30.0 --arg Bool:false --signer creator


flow transactions send ./transactions/auction/create_original_auction.cdc --arg UInt64:2 --arg UFix64:$START \
--arg UFix64:100.0 --arg Bool:true --arg UFix64:600.0 --arg Bool:false --arg UFix64:0.05 --arg UFix64:10.00 \
--arg UFix64:25.0 --arg UFix64:30.0 --arg Bool:false --signer creator

sleep 30
# Filler transaction
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:0 --arg String:"data C" --arg String:"thumbnail C" --arg String:"file C" --signer creator
flow transactions send ./transactions/auction/deposit_bid.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:25.0 --signer nobody

sleep 30
# Filler transaction
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:0 --arg String:"data C" --arg String:"thumbnail C" --arg String:"file C" --signer creator
flow transactions send ./transactions/auction/deposit_bid.cdc --arg Address:$CREATOR --arg UInt64:2 --arg UFix64:25.0 --signer client

sleep 200
# Filler transaction
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:0 --arg String:"data C" --arg String:"thumbnail C" --arg String:"file C" --signer creator
flow transactions send ./transactions/auction/deposit_bid.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:25.0 --signer nobody

sleep 90
# Filler transaction
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:0 --arg String:"data C" --arg String:"thumbnail C" --arg String:"file C" --signer creator

flow transactions send ./transactions/auction/close_auctions.cdc --signer creator

flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR
flow scripts execute ./scripts/collecion.cdc --arg Address:$CLIENT
flow scripts execute ./scripts/collecion.cdc --arg Address:$NOBODY

flow transactions send ./transactions/auction/cancel_auction.cdc --arg UInt64:1 --signer creator

sleep 20
# Filler transaction
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:12 --arg String:"data D" --arg String:"thumbnail D" --arg String:"file D" --signer creator

flow transactions send ./transactions/auction/deposit_bid.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:25.0 --signer nobody
flow transactions send ./transactions/auction/buy_it_now.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:30.0 --signer client

#flow transactions send ./transactions/auction/buy_it_now.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:30.0 --signer nobody
'''

# Transfer NFT
#flow transactions send ./transactions/transfer.cdc --arg Address:$NOBODY --arg UInt64:3 --signer client

# Scripts
#flow scripts execute ./scripts/CheckTokenData.cdc --arg Address:$CLIENT --arg UInt64:1
#flow scripts execute ./scripts/CheckMarketplaceData.cdc --arg Address:$CLIENT
