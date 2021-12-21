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

echo "---------- Nobody Sells 3 -----------"
echo "---------- TokenID: 8 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 8 $START \
100.0 false 0.0 false 0.04 \
13.00 26.0 30.5 --signer nobody #AID: 11  // Auction ID

echo "---------- TokenID: 10 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 10 $START \
100.0 false 0.0 false 0.04 \
10.00 26.0 30.4 --signer client #AID: 12  // Auction ID

echo "---------- TokenID: 14 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 14 $START \
200.0 false 0.0 false 0.025 \
15.00 28.0 30.6 --signer nobody #AID: 13  // Auction ID

echo "---------- TokenID: 12 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 12 $START \
200.0 false 0.0 false 0.025 \
15.00 28.0 30.7 --signer nobody #AID: 14  // Auction ID

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
flow scripts execute ./scripts//wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts//wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts//wallet/collection.cdc $NOBODY
echo CTO
flow scripts execute ./scripts//wallet/collection.cdc $CTO

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
flow scripts execute ./scripts//wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts//wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts//wallet/collection.cdc $NOBODY
echo CTO
flow scripts execute ./scripts//wallet/collection.cdc $CTO

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
flow scripts execute ./scripts//wallet/collection.cdc $CREATOR
echo Client
flow scripts execute ./scripts//wallet/collection.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts//wallet/collection.cdc $NOBODY
echo CTO
flow scripts execute ./scripts//wallet/collection.cdc $CTO
