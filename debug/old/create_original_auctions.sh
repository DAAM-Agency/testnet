echo "Testing Section C ===================="
echo "Testing Auction: Except for Extended Auction, Create Auction"

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO


# Create Original Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# starts in 20 seconds
CURRENT_TIME=$(date +%s)
OFFSET=30.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "START: "$START

echo "========== Create Original Auctions I =========="
echo "---------- A ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
330.0 false 0.0 false 0.05 11.00 \
20.0 30.1 true --signer creator #A MID: 1, AID: 1  // Auction ID

echo "---------- B ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
330.0 false 0.0 true 1.0 12.00 \
25.0 30.2 true --signer creator #B MID: 2, AID: 2

echo "FAIL TEST: #C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_original_auction.cdc 3 $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.3 false --signer creator #C

echo "FAIL TEST: #D does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_original_auction.cdc 4 $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.4 false --signer creator #D

echo "FAIL TEST: #E Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
330.0 false 0.0 false 0.04 13.00 \
26.0 30.5 false --signer creator #E

echo "---------- F ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
330.0 false 0.0 false 0.05 14.00 \
27.0 30.3 true --signer creator #F, MID: 6, AID: 3

echo "---------- G ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
330.0 false 0.0 false 0.025 15.00 \
28.0 0.0 false --signer creator #G, MID: 7, AID: 4

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Reset Copyright
echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

echo "========= Create Original Auctions II ========="
# Auction MID 5, AID: 5 after copyright adjustment. (set to Verfied)
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "START: "$START

echo "---------- E ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
150.0 false 0.0 false 0.04 13.00 \
20.0 30.5 false --signer creator #E AID: 5

# Auction ID: 6, Winner and Collect
echo "---------- H ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 8 $START \
330.0 false 0.0 false 0.025 15.00 \
20.0 30.6 true --signer creator #H, AID: 6

# Auction ID: 7, Bid(s), but auction in finalized by a BuyItNow
echo "---------- I ---------- "
flow transactions send ./transactions/auction/create_original_auction.cdc 9 $START \
330.0 false 0.0 false 0.025 15.00 \
20.0 30.7 true --signer creator #I, AID: 7

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

# ---------------------- BIDS ------------------------------
echo "========= BIDS ========="
sleep 5
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, AID: 1 =========="
echo "Script: timeLeft.cdc Auction #A, AID: 1 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 1

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 1 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 1


flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client, AID 1 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID 1 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client #A

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :AID 1 : 30.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 30.1 --signer nobody #A

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader AID: 1."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false. AID:1"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 19.0 --signer client #A total: 30.0

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1
# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to Creator at closr of auction.

# B ID: 2
# Testing Buy It Now
# Testing Time Left
echo "========== # B, AID: 2 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 2 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 2

echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough. AID: 2"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 2.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much. AID: 2"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 43.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client AID: 2 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer client #I

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 2 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 2

# C & # D non-existenct

# E : MID 5, AID: 5
# reserve price will be met
echo "========= Bid: Nobody AID: 5 11.0 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 5 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 13.0 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 5 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 23.0 --signer client #E

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 17.0 --signer nobody #E // total 30

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 5 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 12.0 --signer client #E // total 35

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc  // total 35
echo "FAIL TEST: Nobody makes the same bid too late. AID: 5"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 5.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late. AID: 5"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 30.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5

# NFT will be sent to Winner.

# F AID: 3
# Also Testing Auction Status
echo "========= Cancel Auction AID: 3 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 3 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 3 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 3 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid: Client AID:3, 20.0 Auction already cancelled. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 20.0 --signer client #G

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

# G AID: 4
echo "========= Auction: # G, AID: 4  ========="
echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 4 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:4, 20.0"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 4 20.0 --signer client #G

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 4"
flow transactions send ./transactions/auction/cancel_auction.cdc 4 --signer creator

echo "FAIL TEST: Script: BuyItNow Creator, AID: 4"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 4 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 4

# H : AID 6
# reserve price will be met and Collected
# test Withdraw
echo "========== # H, AID: 6 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 6 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 6

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:6 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 23.0 --signer client #H

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID:6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H // total 40

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 6, Client: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 30.0 --signer client #H // total 50

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 6 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 6

# I AID: 7
# Testing Buy It Now with Bids.
echo "========== # I, AID: 7 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 7 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 7

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 7 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 20.0 --signer nobody #I

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:7 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 23.0 --signer client #I

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:7 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 9.0 --signer nobody #E // total 29

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client ID: 7 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 7 7.7 --signer client #I 30.7

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 7 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 7

# Withdraw
echo "========== Withdraw =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Client can not withdraw bid, is leader. AID: 6"
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer client #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Withdraw ----------"
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody can not withdraw bid a 2nd time. AID: 6"
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

# NFT will be 'Collected' by Winner.

echo "Testing Section D ===================="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO


echo "Testing Auction: Serial Minter"
# Verify time left for auction #2
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2
# Verify Auction status #2
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 2 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 2

# Test Serial Minter
echo "========== Testing Serial Minter AID: 2 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (1): Nobody 30.2, AID: 2 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (2) Nobody 30.2, AID: 2 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints. AID: 12"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 12 30.2 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts/wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/wallet/collection.cdc $NOBODY

# End of Auctions
echo "========== Testing Section E =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

sleep 160
# Winner Colection
echo "========= Winner Tests ========="

echo "Script: timeLeft.cdc Auction #H, AID: 6"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 6

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT. AID: 6"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer nobody

echo "---------- Winner Collect: Client, #G AID: 6 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer client

echo "----------- Script: BuyItNow Creator, AID: 6 (false) no more reprints ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 6

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO


# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts/wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/wallet/collection.cdc $NOBODY

echo "Testing Section F ===================="

echo "Script: timeLeft.cdc Auction #H, AID: 6"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 6
sleep 50

# Test Serial Minter
echo "========== Testing Serial Minter AID: 6 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (1): Nobody AID: 6 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 6 30.6 --signer nobody #H

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (2) 30.6, Nobody AID: 6 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Testing: endReprint =========="
flow transactions send ./transactions/auction/end_reprints.cdc 6 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints due to endReprint (previous) AID: 6"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

# Close Auctions
# Also Testing Time Left
echo "Script: timeLeft.cdc Auction #B, AID: 2"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Close Auctions ========="
flow transactions send ./transactions/auction/close_auctions.cdc --gas-limit 9999 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST Script: timeLeft.cdc Auction #B, AID: 2 already closed."
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

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
echo "========= Get Auctions ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT
flow scripts execute ./scripts/auction/get_auctions.cdc $NOBODY

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts/wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/wallet/collection.cdc $NOBODY