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
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin / Creator
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer admin

# (Re)Invite Creator & Accept
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# (Re)Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Submit 2 Metadata: #1 Solo, #2 Series(of 2)
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data A" "thumbnail A" "file A" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator

# Approve the Metadatas
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2

# Request Royality
flow transactions send ./transactions/request/accept_default.cdc 2 0.15  --signer creator
flow transactions send ./transactions/request/accept_default.cdc 1 0.20  --signer creator

# Change Copyright
flow transactions send ./transactions/admin/change_copyright.cdc 1 3 --signer admin
flow transactions send ./transactions/admin/change_copyright.cdc 2 3 --signer admin

# Change Creator Status
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer admin2
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer admin2

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

flow scripts execute ./scripts/collecion.cdc $CREATOR
flow scripts execute ./scripts/collecion.cdc $CLIENT
flow scripts execute ./scripts/collecion.cdc $NOBODY

# tokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
100.0 false 0.0 false 0.05 10.00 \
25.0 30.0 false --signer creator


flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
100.0 false 0.0 false 0.05 10.00 \
25.0 30.0 true --signer creator

sleep 30
# Filler transaction
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 25.0 --signer nobody

sleep 30
# Filler transaction // Auction already Ended, should fail
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 38.0 --signer client
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 39.0 --signer nobody

# Filler transaction
sleep 130
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE
flow transactions send ./transactions/auction/close_auctions.cdc --signer creator

sleep 20
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE
flow scripts execute ./scripts/collecion.cdc $CREATOR
flow scripts execute ./scripts/collecion.cdc $CLIENT
flow scripts execute ./scripts/collecion.cdc $NOBODY

#flow transactions send ./transactions/auction/cancel_auction.cdc 1 --signer creator

#flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 1 30.0 --signer nobody

# Transfer NFT
#flow transactions send ./transactions/transfer.cdc $NOBODY 3 --signer client

# Scripts
#flow scripts execute ./scripts/CheckTokenData.cdc $CLIENT 1
#flow scripts execute ./scripts/CheckMarketplaceData.cdc $CLIENT
