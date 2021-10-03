# verify transactions

# Setup Profiles
echo "---------- Setup Profiles ----------"
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer nobody

# Setup DAAM Accounts
echo "---------- Setup DAAM Accounts ----------"
flow transactions send ./transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./transactions/setup_daam_account.cdc --signer creator
flow transactions send ./transactions/setup_daam_account.cdc --signer client
flow transactions send ./transactions/setup_daam_account.cdc --signer admin2

# Setup Auction Wallets
echo "---------- Setup Auction Wallets ----------"
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer nobody
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin2

# ACCOUNTS SETUP END --------------------------- 

# Invite Creator & Accept
echo "---------- Invite Creator ----------"
# accept
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
# decline
flow transactions send ./transactions/admin/invite_creator.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc false --signer admin2

# Invite Admin #2
echo "---------- Invite Admin ----------"
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2
#accept
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin / Creator
echo "---------- Remove Admin & Creator ----------"
# admin
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2
# creator
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer admin

# Delete / Reset Addresses
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

# (Re)Invite Creator & Accept
echo "---------- Re(Invite) Admin & Creator ----------"
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# (Re)Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "---------- Submite NFTs ----------"
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data A" "thumbnail A" "file A" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data C" "thumbnail C" "file C" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data D" "thumbnail D" "file D" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data E" "thumbnail E" "file E" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data F" "thumbnail F" "file F" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 10 "data G" "thumbnail G" "file G" --signer creator

echo "---------- Veriy Metadata ----------"
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Remove Metadata [MID]
echo "---------- Remove Metadata Submission ----------"
flow transactions send ./transactions/creator/remove_submission.cdc 3 --signer creator  #C MID 3 

echo "---------- Veriy Metadata ----------"
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR #C No longer exist

# Approve the Metadatas [MID, Status]
echo "---------- Approve Metadata Submissions ----------"
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin   # MID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2  # MID 2

echo "Fail Test: Metadata removed by Creator"
flow transactions send ./transactions/admin/change_metadata_status.cdc 3 true --signer admin2  # MID 3 #C No longer exist

flow transactions send ./transactions/admin/change_metadata_status.cdc 4 false --signer admin2 #D Disapproved by Admin, No longer exist

flow transactions send ./transactions/admin/change_metadata_status.cdc 5 true --signer admin2  # MID 5
flow transactions send ./transactions/admin/change_metadata_status.cdc 6 true --signer admin2  # MID 6
flow transactions send ./transactions/admin/change_metadata_status.cdc 7 true --signer admin2  # MID 7

echo "---------- metadata status ----------"
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Request Royality [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "FAIL Test"
flow transactions send ./transactions/request/accept_default.cdc 2 0.99  --signer creator #B
echo "FAIL Test"
flow transactions send ./transactions/request/accept_default.cdc 2 0.31 --signer creator #B

echo "---------- Accept Defaults 10 & 20 ----------"
flow transactions send ./transactions/request/accept_default.cdc 1 0.10 --signer creator #A
flow transactions send ./transactions/request/accept_default.cdc 2 0.20 --signer creator #B

echo "FAIL Test: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/request/accept_default.cdc 3 0.12 --signer creator #C

flow transactions send ./transactions/request/accept_default.cdc 4 0.18 --signer creator #D
flow transactions send ./transactions/request/accept_default.cdc 5 0.20 --signer creator #E
flow transactions send ./transactions/request/accept_default.cdc 6 0.25 --signer creator #F
flow transactions send ./transactions/request/accept_default.cdc 7 0.30 --signer creator #G

# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied
echo "---------- Change Copyright Status ----------"
flow transactions send ./transactions/admin/change_copyright.cdc 1 3 --signer admin #A Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 2 3 --signer admin #B Verfied

echo "FAIL Test: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/admin/change_copyright.cdc 3 3 --signer admin #B Verfied

echo "FAIL Test: #D does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/admin/change_copyright.cdc 4 3 --signer admin #B Verfied

flow transactions send ./transactions/admin/change_copyright.cdc 5 1 --signer admin #E Claim

flow transactions send ./transactions/admin/change_copyright.cdc 6 3 --signer admin #F Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 7 3 --signer admin #G Verfied

# Change Creator Status
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer admin2
# Fail: Creator is set to False
echo "FAIL Test"
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data test_copyright" "thumbnail cp" "file cp" --signer creator

echo "---------- Change Creator Status ----------"
# set status back to true
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer admin2

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

# Look at participents collections
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# tokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

echo "---------- Create Original Auctions ----------"
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
100.0 false 0.0 false 0.05 11.00 \
20.0 0.0 false --signer creator #A MID: 1, ID: 1

flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
100.0 false 0.0 false 0.04 12.00 \
25.0 30.0 true --signer creator #B MID: 2, ID: 2

echo "FAIL Test #C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_original_auction.cdc 3 $START \
100.0 false 0.0 false 0.04 10.00 \
26.0 30.0 true --signer creator #C

echo "FAIL Test: #D does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_original_auction.cdc 4 $START \
100.0 false 0.0 false 0.04 10.00 \
26.0 30.0 true --signer creator #D

echo "FAIL Test: #E Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 13.00 \
26.0 30.0 true --signer creator #E

flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
200.0 false 0.0 false 0.05 14.00 \
27.0 35.0 true --signer creator #F, MID: 6, ID: 3

flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 15.00 \
28.0 40.0 true --signer creator #G, MID: 7, ID: 4

# Verify Metadata
echo "---------- Verify Metadata ----------"
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Reset Copyright
echo "---------- Reset Copyright ----------"
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

# Auction MID 5, ID: 5 after copyright adjustment. (set to Verfied)
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 13.00 \
26.0 30.0 true --signer creator #E ID: 5

# Auction Scripts
echo "---------- Verify Auctions ----------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
'''
# ---------------------- BIDS ------------------------------
# A ID: 1
# The reserve price will NOT be met.
echo "FAIL Test: Bid too low ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 10.99 --signer nobody #A

echo "---------- Nobody Bids ID:1 11.0 ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer nobody #A

echo "FAIL Test: Bid too low ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client #A

echo "FAIL Test: Bid did not meet miniumum increment ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.01 --signer client #A

echo "FAil Test: Verify Buy It Now option is false."
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 1 50.0 --signer client #A

# NFT will be transfered to Creator. Will NOT meet reserve price.
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 12.0 --signer client #A

# B ID: 2
# Testing Buy It Now
echo "FAIL Test: Did not meet Buy It Now: Not Enough ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 28.0 --signer client #B

echo "FAIL Test: Did not meet Buy It Now: Too much ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 33.0 --signer client #B
'''
'''
echo "--------- Buy It Now ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.0 --signer client #B
'''
# C & # D non-existenct

# E : ID 5
# Winner 
echo "--------- Winner Test ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 13.0 --signer client #E

echo "--------- Nobody Bid: 20 ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 20.0 --signer nobody #E

echo "---------  Client Bid: 24 ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 24.0 --signer client #E

echo "---------  Nobody Bid: 30 ----------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 30.0 --signer nobody #E

sleep 130

# Winner Collect

# Verify Collection
echo "----- verify collections -----"
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# Cancel Auction

# Filler transaction

echo "---------- Close Auctions  ----------"
# check Creators auctions
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow transactions send ./transactions/auction/close_auctions.cdc --signer creator
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

sleep 20
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
# Look at participents collections
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY



# Check Auction Wallets
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT
flow scripts execute ./scripts/auction/get_auctions.cdc $NOBODY

flow transactions send ./transactions/auction/create_auction.cdc 2 $START \
100.0 false 0.0 false 0.04 15.00 \
101.0 70.0 true --signer nobody #B
'''