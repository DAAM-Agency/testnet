# verify transactions

# Setup Profiles
echo "========= Setup Profiles ========="
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer nobody

# Setup DAAM Accounts
echo "========= Setup DAAM Accounts ========="
flow transactions send ./transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./transactions/setup_daam_account.cdc --signer creator
flow transactions send ./transactions/setup_daam_account.cdc --signer client
flow transactions send ./transactions/setup_daam_account.cdc --signer admin2

# Setup Auction Wallets
echo "========= Setup Auction Wallets ========="
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer nobody
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin2

# ACCOUNTS SETUP END --------------------------- 

# Invite Creator & Accept
echo "========= Invite Creator ========="
# accept
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
# decline
flow transactions send ./transactions/admin/invite_creator.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc false --signer admin2

# Invite Admin #2
echo "========= Invite Admin ========="
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2
#accept
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin / Creator
echo "========= Remove Admin & Creator ========="
# admin
echo "---------- Get 1 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer client

echo "---------- Get 2 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2

# creator
echo "FAIL TEST: Removing Creator: Not Admin"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer client

echo "---------- Remove Creator ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer admin

# Delete / Reset Addresses
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

# (Re)Invite Creator & Accept
echo "========= Re(Invite) Admin & Creator ========="

echo "---------- Invite Creator ----------"
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
echo "----------- Decline Invitation ----------"
flow transactions send ./transactions/answer_creator_invite.cdc false --signer creator

echo "----------- Invite: Creator -----------"
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
echo "----------- Accept Invitation ----------"
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# (Re)Invite Admin #2
echo "----------- Invite: Admin -----------"
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
echo "Decline Invite: Admin"
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2

echo "----------- Invite: Admin -----------"
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
echo "Accept Invite: Admin"
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submite NFTs ========="
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data A" "thumbnail A" "file A" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data C" "thumbnail C" "file C" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data D" "thumbnail D" "file D" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data E" "thumbnail E" "file E" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data F" "thumbnail F" "file F" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 10 "data G" "thumbnail G" "file G" --signer creator

echo "========= Veriy Metadata ========="
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Remove Metadata [MID]
echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc 3 --signer creator  #C MID 3 

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR #C No longer exist

# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin   # MID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2  # MID 2

echo "FAIL TEST: Metadata removed by Creator"
flow transactions send ./transactions/admin/change_metadata_status.cdc 3 true --signer admin2  # MID 3 #C No longer exist
echo "---------- Disapprove Metadata by Admin----------"
flow transactions send ./transactions/admin/change_metadata_status.cdc 4 false --signer admin2 #D Disapproved by Admin, No longer exist

flow transactions send ./transactions/admin/change_metadata_status.cdc 5 true --signer admin2  # MID 5
flow transactions send ./transactions/admin/change_metadata_status.cdc 6 true --signer admin2  # MID 6
flow transactions send ./transactions/admin/change_metadata_status.cdc 7 true --signer admin2  # MID 7

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Request Royality [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "========== Select Royality Rate =========="
echo "FAIL TEST: too low"
flow transactions send ./transactions/request/accept_default.cdc 2 0.99  --signer creator #B
echo "FAIL TEST: too high"
flow transactions send ./transactions/request/accept_default.cdc 2 0.31 --signer creator #B

echo "---------- Accept Defaults 10 & 20 ----------"
flow transactions send ./transactions/request/accept_default.cdc 1 0.10 --signer creator #A
flow transactions send ./transactions/request/accept_default.cdc 2 0.20 --signer creator #B

echo "FAIL TEST: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/request/accept_default.cdc 3 0.12 --signer creator #C

flow transactions send ./transactions/request/accept_default.cdc 4 0.18 --signer creator #D
flow transactions send ./transactions/request/accept_default.cdc 5 0.20 --signer creator #E
flow transactions send ./transactions/request/accept_default.cdc 6 0.25 --signer creator #F
flow transactions send ./transactions/request/accept_default.cdc 7 0.30 --signer creator #G

# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied
echo "========== Change Copyright Status =========="
flow transactions send ./transactions/admin/change_copyright.cdc 1 3 --signer admin #A Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 2 3 --signer admin #B Verfied

echo "FAIL TEST: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/admin/change_copyright.cdc 3 3 --signer admin #C Verfied

echo "Note: Disapproved by Admin, but Copyright can still be modified."
flow transactions send ./transactions/admin/change_copyright.cdc 4 3 --signer admin #D Verfied

flow transactions send ./transactions/admin/change_copyright.cdc 5 1 --signer admin #E Claim

flow transactions send ./transactions/admin/change_copyright.cdc 6 3 --signer admin #F Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 7 3 --signer admin #G Verfied

# Change Creator Status
echo "========== Change Creator Status (to verify access) =========="
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer admin2

# Fail: Creator is set to False
echo "FAIL TEST: Submit NFT will fail, Creator has no access."
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data test_copyright" "thumbnail cp" "file cp" --signer creator

# set status back to true
echo "========== Change Creator Status (return to true) =========="
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer admin2

# Look at participents collections
echo "---------- View Collections ----------"
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# Create Original Auction Tests
# tokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

echo "========== Create Original Auctions I =========="
echo "---------- A ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
100.0 false 0.0 false 0.05 11.00 \
20.0 30.0 false --signer creator #A MID: 1, ID: 1

echo "---------- B ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
100.0 false 0.0 true 1.0 12.00 \
25.0 30.0 false --signer creator #B MID: 2, ID: 2

echo "FAIL TEST: #C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_original_auction.cdc 3 $START \
100.0 false 0.0 false 0.04 10.00 \
26.0 30.0 true --signer creator #C

echo "FAIL TEST: #D does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_original_auction.cdc 4 $START \
100.0 false 0.0 false 0.04 10.00 \
26.0 30.0 true --signer creator #D

echo "FAIL TEST: #E Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 13.00 \
26.0 30.0 true --signer creator #E

echo "---------- F ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
200.0 false 0.0 false 0.05 14.00 \
27.0 30.0 true --signer creator #F, MID: 6, ID: 3

echo "---------- G ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 15.00 \
28.0 0.0 true --signer creator #G, MID: 7, ID: 4

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Reset Copyright
echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

echo "========= Create Original Auctions II ========="
# Auction MID 5, ID: 5 after copyright adjustment. (set to Verfied)
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

echo "---------- E ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 13.00 \
26.0 30.0 true --signer creator #E ID: 5

# Auction ID: 6, Winner and Collect
echo "---------- H ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 15.00 \
28.0 30.0 true --signer creator #H, ID: 6

# Auction ID: 7, Bid(s), but auction in finalized by a BuyItNow
echo "---------- I ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 15.00 \
28.0 30.0 true --signer creator #I, ID: 7

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

# ---------------------- BIDS ------------------------------
echo "========= BIDS ========="
sleep 20
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, ID: 1 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client :ID 1 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :ID 1 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :ID 1 : 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 30.0 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 20.0 --signer client #A

# NFT will be sent back to Creator at closr of auction.

# B ID: 2
# Testing Buy It Now
# Testing Time Left
echo "========== Script: timeLeft.cdc Auction #B, ID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2
echo "========== # B, ID: 2 =========="
sleep 5
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough."
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 2.0 --signer client #I

sleep 5
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much."
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 43.0 --signer client #I

sleep 5
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client ID: 2 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, ID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

# C & # D non-existenct

# E : ID 5 
# reserve price will be met
echo "========= Bid: Nobody ID: 5 11.0 ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody ID: 5 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 13.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :ID: 5 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 23.0 --signer client #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody ID: 5 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 17.0 --signer nobody #E // total 30

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client ID: 5 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 12.0 --signer client #E // total 35

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc  // total 35
echo "FAIL TEST: Nobody makes the same bid too late."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 5.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 30.0 --signer nobody #E

# NFT will be sent to Winner.

# F ID: 3
# Also Testing Auction Status
echo "========= Cancel Auction ID: 3 ========="

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 3 =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: ID: 3 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 3 --signer creator

echo "========= Auction Status: ID: 3 =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

# G ID: 4
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction: 4 # G ========="
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 4 31.0 --signer client #G

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: ID: 4"
flow transactions send ./transactions/auction/cancel_auction.cdc 4 --signer creator

echo "----------- Script: buy_it_now_status.cdc = true ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 6

# H : ID 6
# reserve price will be met and Collected
# test Withdraw
echo "========== # H, ID 6 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID: 6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:6 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 23.0 --signer client #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H // total 40

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BuyItNow: ID 6, Client: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 30.0 --signer client #H // total 50

# I ID: 7
# Testing Buy It Now with Bids.
echo "========== # I, ID 7 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID: 7 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 20.0 --signer nobody #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:7 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 23.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:7 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 9.0 --signer nobody #E // total 29

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client ID: 2 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 7 7.0 --signer client #I

# Withdraw
echo "========== Withdraw =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Client can not withdraw bid, is leader."
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer client #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Withdraw ----------"
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody can not withdraw bid a 2nd time."
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

# NFT will be 'Collected' by Winner.

# End of Auctions
sleep 160

# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer nobody

echo "---------- Winner Collect: Client, #G ID: 6 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer client

echo "----------- Script: buy_it_now_status.cdc = false ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 6

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# Close Auctions
# Also Testing Time Left
echo "Script: timeLeft.cdc Auction #B, ID: 2"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Close Auctions ========="
flow transactions send ./transactions/auction/close_auctions.cdc --gas-limit 9999 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "Script: timeLeft.cdc Auction #B, ID: 2"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# Script: check_auction_wallet
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Script: Check Auction Wallet ========="
echo "Creator"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $CREATOR
echo "Client"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $CLIENT
echo "Nobody"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $NOBODY

# Check Auction Wallets
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Auctions Wallets ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT
flow scripts execute ./scripts/auction/get_auctions.cdc $NOBODY
