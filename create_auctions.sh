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
echo CTO
flow scripts execute ./scripts/collecion.cdc $CTO
# "Creator: [10, 3, 4]"
# "Client : [2, 7, 6, 5]"
# "Nobody : [8, 9, 11, 12, 1]"

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO


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
echo "---------- Client Sells All (4) -----------"

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

echo "---------- Nobody Sells 3 -----------"

echo "---------- TokenID: 8 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 8 $START \
100.0 false 0.0 false 0.04 \
13.00 26.0 30.5 --signer nobody #AID: 12  // Auction ID

echo "---------- TokenID: 9 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 9 $START \
200.0 false 0.0 false 0.025 \
15.00 28.0 30.6 --signer nobody #AID: 13  // Auction ID

echo "---------- TokenID: 11 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 11 $START \
200.0 false 0.0 false 0.025 \
15.00 28.0 30.7 --signer nobody #AID: 14  // Auction ID

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT
flow scripts execute ./scripts/auction/get_auctions.cdc $NOBODY


# ---------------------- BIDS ------------------------------
echo "========= BIDS ========="
sleep 20
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, AID: 8 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 8 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 8

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client, AID 8 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID 8 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.0 --signer cto #A

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :AID 8 : 30.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 30.1 --signer nobody #A

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader. AID: 8"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false. AID: 8"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 19.0 --signer cto #A total: 30.0

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 8 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 8

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to CLIENT at closr of auction.

# B ID: 2
# Testing Buy It Now
# Testing Time Left
echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9
echo "========== AID: 9 =========="

echo "---------- Auction Item, AID: 9 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 2.0 --signer cto

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 43.0 --signer cto

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CTO AID: 9 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 30.2 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 9 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 9

# reserve price will be met
echo "========= AID: 10 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 10 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 10


flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 10 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 13.0 --signer nobody

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 10 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 23.0 --signer cto

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 10 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 17.0 --signer nobody # total 30

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 10 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 12.0 --signer cto # total 35

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody makes the same bid too late. AID: 10"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 5.0 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late.  AID: 10"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 10 30.0 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 10 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 10

# NFT will be sent to Winner.


# F AID: 11
# Also Testing Auction Status
echo "========= Cancel Auction AID: 11 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 11 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 11

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 11 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 11

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low. AID: 11"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 11 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 11 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 11 --signer client

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 11 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 11


# AID: 12
echo "========= AID: 12  ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 12 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO AID: 12, 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 12 20.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 12"
flow transactions send ./transactions/auction/cancel_auction.cdc 12 --signer nobody

echo "----------- Script: BuyItNow Creator, AID: 12 (false) ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 12 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 12

# AID 13
# reserve price will be met and Collected
# test Withdraw
echo "========== # AID: 13 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 13 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 13

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID: 13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO AID:13 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 23.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client # total 40

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 13, CTO: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 30.0 --signer cto # total 50

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO


# Withdraw
echo "========== Withdraw =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Client can not withdraw bid, is leader."
flow transactions send ./transactions/auction/withdraw_bid.cdc $NOBODY 13 --signer cto

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Withdraw ----------"
flow transactions send ./transactions/auction/withdraw_bid.cdc $NOBODY 13 --signer client

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody can not withdraw bid a 2nd time. AID: 13"
flow transactions send ./transactions/auction/withdraw_bid.cdc $NOBODY 13 --signer client

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 13 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 13

# AID: 14
# Testing Buy It Now with Bids.
echo "========== # AID: 14 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 14 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 14

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID: 14 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO ID:14 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 23.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:14 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 9.0 --signer client # total 29

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CTO ID: 14 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 14 7.7 --signer cto # total 30.7

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 14 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 14

# NFT will be 'Collected' by Winner.

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
echo CTO
flow scripts execute ./scripts/collecion.cdc $CTO

# End of Auctions
echo "========== Testing Section E =========="
sleep 160

# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT. AID: 10"
flow transactions send ./transactions/auction/winner_collect.cdc $CLIENT 10 --signer nobody

echo "---------- Winner Collect: Cto, AID: 10 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CLIENT 10 --signer cto

echo "FAIL TEST: Script: BuyItNow Creator, AID: 10"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CLIENT 10

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
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
echo CTO
flow scripts execute ./scripts/collecion.cdc $CTO

echo "Testing Section F ===================="

echo "========= Close Auctions ========="
flow transactions send ./transactions/auction/close_auctions.cdc --gas-limit 9999 --signer client
flow transactions send ./transactions/auction/close_auctions.cdc --gas-limit 9999 --signer nobody

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
echo "========= Script: Check Auction Wallet ========="
echo "Creator"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $CREATOR
echo "Client"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $CLIENT
echo "Nobody"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $NOBODY
echo "CTO"
flow scripts execute ./scripts/auction/check_auction_wallet.cdc $CTO

# Check Auction Wallets
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Auctions Wallets ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CLIENT
flow scripts execute ./scripts/auction/get_auctions.cdc $NOBODY
flow scripts execute ./scripts/auction/get_auctions.cdc $CTO

# Verify Collection
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Verify Collections ========="
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
echo CTO
flow scripts execute ./scripts/collecion.cdc $CTO
