echo "Testing Section G ===================="
echo "Testing: Create Auction, excpet for Extended Auctions."

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
# "Creator: [10, 3, 4]"
# "Client : [2, 7, 6, 5]"
# "Nobody : [8, 9, 11, 12, 1]"


# Create Auction Tests
# TokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64,
# startingBid: UFix64, reserve: UFix64, buyNow: UFix64

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

echo "========== Create Auctions I =========="
echo "---------- Client Sells All -----------"

echo "---------- TokenID: 2 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 2 $START \
100.0 false 0.0 false 0.05 \
11.00 20.0 30.1 --signer client #AID: 8  // Auction ID

echo "---------- TokenID: 7 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 7 $START \
100.0 false 0.0 true 1.0 \
12.00 25.0 30.2 --signer client #AID: 9  // Auction ID

echo "---------- TokenID: 6 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 6 $START \
100.0 false 0.0 false 0.04 \
10.00 26.0 30.3 --signer client #AID: 10  // Auction ID

echo "---------- TokenID: 5 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 \
10.00 26.0 30.4 --signer client #AID: 11  // Auction ID

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT


# ---------------------- BIDS ------------------------------
echo "========= BIDS ========="
sleep 20
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, AID: 8 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client, AID 8 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID 8 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.0 --signer cto #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :AID 8 : 30.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 30.1 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader."
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false."
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 19.0 --signer cto #A total: 30.0

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 8 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 8
# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to CLIENT at closr of auction.

# B ID: 2
# Testing Buy It Now
# Testing Time Left
echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9
echo "========== AID: 9 =========="

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough."
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 2.0 --signer cto #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much."
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 43.0 --signer cto #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CTO AID: 9 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 30.2 --signer cto #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 9 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 9

# C & # D non-existenct
'''
# E : MID 5, AID: 5
# reserve price will be met
echo "========= AID: 10 ========="

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 10 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 13.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 5 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 23.0 --signer cto #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 17.0 --signer nobody #E // total 30

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 5 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 12.0 --signer cto #E // total 35

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc  // total 35
echo "FAIL TEST: Nobody makes the same bid too late."
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 5.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 10 30.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 10

# NFT will be sent to Winner.

# F AID: 3
# Also Testing Auction Status
echo "========= Cancel Auction AID: 3 ========="

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 3 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 3 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

# G AID: 4
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction: # G, AID: 4  ========="
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 4 20.0 --signer cto #G

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 4"
flow transactions send ./transactions/auction/cancel_auction.cdc 4 --signer creator

echo "FAIL TEST: No Buy It Now option for this auction."
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 4 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 4

# H : AID 6
# reserve price will be met and Collected
# test Withdraw
echo "========== # H, AID: 6 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:6 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 23.0 --signer cto #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID:6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H // total 40

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 6, Client: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 30.0 --signer cto #H // total 50

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 6 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 6

# I AID: 7
# Testing Buy It Now with Bids.
echo "========== # I, AID: 7 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 7 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 20.0 --signer nobody #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:7 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 23.0 --signer cto #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:7 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 9.0 --signer nobody #E // total 29

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client ID: 7 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 7 7.7 --signer cto #I 30.7

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 7 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 7

# Withdraw
echo "========== Withdraw =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Client can not withdraw bid, is leader."
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer cto #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Withdraw ----------"
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody can not withdraw bid a 2nd time."
flow transactions send ./transactions/auction/withdraw_bid.cdc $CREATOR 6 --signer nobody #E

# NFT will be 'Collected' by Winner.

echo "Testing Section D ===================="

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
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow # 1 AID: 2----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow # 2 AID: 2----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 12 30.2 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY

# End of Auctions
echo "========== Testing Section E =========="
sleep 160

# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer nobody

echo "---------- Winner Collect: Client, #G AID: 6 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 6 --signer cto

echo "FAIL TEST: BuyItNowStatus: (false) Auction is over."
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

echo "Testing Section F ===================="

echo "Script: timeLeft.cdc Auction #H, AID: 6"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 6
sleep 50

# Test Serial Minter
echo "========== Testing Serial Minter AID: 6 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow # 1 AID: 6 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Testing: endReprint =========="
flow transactions send ./transactions/auction/end_reprints.cdc 6

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints due to endReprint (previous)"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR


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

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "Script: timeLeft.cdc Auction #B, AID: 2"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2
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

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
'''
