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

# ACCOUNTS SETUP END --------------------------- 

# Invite Creator & Accept
# accept
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
# decline
flow transactions send ./transactions/admin/invite_creator.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc false --signer admin2

# Invite Admin #2
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2
#accept
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin / Creator
# admin
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2
# creator
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer admin

# Delete / Reset Addresses
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

# (Re)Invite Creator & Accept
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# (Re)Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright, #F Unlimited Print
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data A" "thumbnail A" "file A" --signer creator # MID 1
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator # MID 2
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data C" "thumbnail C" "file C" --signer creator # MID 3
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data D" "thumbnail D" "file D" --signer creator # MID 4
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data E" "thumbnail E" "file E" --signer creator # MID 5
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data F" "thumbnail F" "file F" --signer creator # MID 6
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data G" "thumbnail G" "file G" --signer creator # MID 7
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Remove Metadata [MID]
flow transacitons send ./transacions/creator/remove_submission.cdc 3 #C MID 3 
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR #C MID 3, No longer exist

# Approve the Metadatas [MID, Status]
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin   # MID 1 = ID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2  # MID 2 = ID 2
flow transactions send ./transactions/admin/change_metadata_status.cdc 4 false --signer admin2 #D Disapproved by Admin, No longer exist
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Request Royality [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "FAIL Test"
flow transactions send ./transactions/request/accept_default.cdc 2 0.9  --signer creator #B
echo "FAIL Test"
flow transactions send ./transactions/request/accept_default.cdc 2 0.31 --signer creator #B

flow transactions send ./transactions/request/accept_default.cdc 2 0.15 --signer creator #B
flow transactions send ./transactions/request/accept_default.cdc 1 0.20 --signer creator #A

# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 1 3 --signer admin #A Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 2 3 --signer admin #B Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 5 1 --signer admin #E Claim
flow transactions send ./transactions/admin/change_copyright.cdc 6 3 --signer admin #F Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 7 3 --signer admin #G Verfied

# Change Creator Status
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer admin2
# Fail: Creator is set to False
echo "FAIL Test"
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data test_copyright" "thumbnail cp" "file cp" --signer creator
# set status back to true
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer admin2

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

# Look at participents collections
flow scripts execute ./scripts/collecion.cdc $CREATOR
flow scripts execute ./scripts/collecion.cdc $CLIENT
flow scripts execute ./scripts/collecion.cdc $NOBODY

# tokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
100.0 false 0.0 false 0.05 10.00 \
25.0 0.0 false --signer creator #A

flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
100.0 false 0.0 false 0.04 11.00 \
26.0 30.0 true --signer creator #B

flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
200.0 false 0.0 true 25.00 12.00 \
27.0 32.0 true --signer creator #F

flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 14.00 \
28.0 40.0 true --signer creator #G

# Fail: Copyright set to Fraud
echo "FAIL Test"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
200.0 false 0.0 false 0.035 16.00 \
29.0 50.0 true --signer creator #E

# Reset Copyright
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

sleep 30
# Filler transaction
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 24.0 --signer nobody #A
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/collecion.cdc $CREATOR
flow scripts execute ./scripts/collecion.cdc $CLIENT
flow scripts execute ./scripts/collecion.cdc $NOBODY

sleep 30
# Filler transaction // Auction already Ended, should fail
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 25.0 --signer client #B
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 30.0 --signer nobody #B

# Filler transaction
sleep 130
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/close_auctions.cdc --signer creator

sleep 20
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
# Look at participents collections
flow scripts execute ./scripts/collecion.cdc $CREATOR
flow scripts execute ./scripts/collecion.cdc $CLIENT
flow scripts execute ./scripts/collecion.cdc $NOBODY

# Cancel Auction
flow transactions send ./transactions/auction/cancel_auction.cdc 6 --signer creator

# Buy It Now
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 7 28.0 --signer nobody

# Auction Scripts
# check Creators' auctions
flow scripts execute ./scripts/get_auctions.cdc $CREATOR
# Check Auction Wallets
flow scripts execute ./scripts/check_auction_wallet.cdc $CREATOR
flow scripts execute ./scripts/check_auction_wallet.cdc $CLIENT
flow scripts execute ./scripts/check_auction_wallet.cdc $NOBODY

flow transactions send ./transactions/auction/create_auction.cdc 2 $START \
100.0 false 0.0 false 0.04 15.00 \
101.0 70.0 true --signer nobody #B
