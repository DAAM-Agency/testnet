displayFUSD() {
    echo "---------- FUSD ----------"
    echo "CREATOR FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CREATOR | jq -c ' .value | .value'
    echo "CREATOR2 FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CREATOR2 | jq -c ' .value | .value'
    echo "CLIENT FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'
    echo "CLIENT2 FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'
    echo "NOBODY FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'
    echo "AGENCY FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $AGENCY| jq -c ' .value | .value'
    echo "CTO FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CTO| jq -c ' .value | .value'
}

echo "Testing Section C ===================="
echo "Testing Auction: Direct Purchase & Extended Auctions."
# Note: A Direct Purchase is an Auction with a minBid = nil

# Create Original Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# starts in 30 seconds

displayFUSD()

CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "Start Time: "$START

echo "========== Create Extended Auctions I =========="
echo "---------- A ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 1 $START \
100.0 false 0.0 false 0.05 nil \
20.0 30.1 true nil --signer creator #A MID: 1, AID: 1  // Auction ID

echo "---------- B ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 2 $START \
40.0 true 60.0 true 5.0 12.0 \
25.0 0.0 false nil --signer creator #B MID: 2, AID: 2

echo "FAIL TEST: #C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_auction.cdc 3 $START \
100.0 false 0.0 false 0.04 nil \
26.0 30.3 false nil --signer creator #C

echo "FAIL TEST: #D does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_auction.cdc 4 $START \
100.0 false 0.0 false 0.04 nil \
26.0 30.4 false nil --signer creator #D

echo "FAIL TEST: #E Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_auction.cdc 5 $START \
100.0 false 0.0 false 0.04 nil \
26.0 30.5 false nil --signer creator #E

echo "---------- F ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 6 $START \
200.0 true 60.0 false 0.05 16.0 \
27.0 30.3 true nil --signer creator #F, MID: 6, AID: 3

echo "---------- G ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 7 $START \
200.0 false 0.0 false 0.025 nil \
28.0 30.7 false nil --signer creator #G, MID: 7, AID: 4

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR

# Reset Copyright
echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

echo "========= Create Original Auctions II ========="
# Auction MID 5, AID: 5 after copyright adjustment. (set to Verfied)
CURRENT_TIME=$(date +%s)
OFFSET=10.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "Start Time: "$START

# Auction ID: 5, Extended Auction, Reserve Price: Not Meet
echo "---------- E ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 5 $START \
60.0 true 60.0 false 0.04 15.0 \
26.0 30.5 true --signer creator #E AID: 5

# Auction ID: 6, Extended Auction, Reserve Price: Meet
echo "---------- H ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 8 $START \
200.0 false 0.0 false 0.025 nil \
28.0 30.6 true --signer creator #H, AID: 6

# Auction ID: 7, Bid(s), but auction in finalized by a BuyItNow
echo "---------- I ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 9 $START \
200.0 false 0.0 false 0.025 nil \
28.0 30.7 false --signer creator #I, AID: 7

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

# ---------------------- BIDS ------------------------------
echo "========= BIDS ========="
sleep 20
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, AID: 1 =========="

displayFUSD()

echo "---------- Auction Item, AID: 1 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 1

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No Bidding. Direct Purchase Only"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: Wrong Amount."
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 1 30.0 --signer client #A 

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR 2 $CLIENT | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 1 $BUYITNOW --signer client #A

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1
# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to Creator at closr of auction.

echo "========== # B, AID: 2 =========="

displayFUSD()

echo "---------- Auction Item, AID: 2 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 2

# B ID: 2
# Testing Buy It Now
# Testing Time Left
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 2 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 13.0 --signer client #B

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 2 : 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 20.0 --signer nobody #B

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 2 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 2

# C & # D non-existenct

echo "========== # E, AID: 5 =========="

displayFUSD()

echo "---------- Auction Item, AID: 5 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 5

# E : MID 5, AID: 5
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #E, AID: 5 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 15.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 15.0 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

sleep 20

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #E, AID: 5 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5

sleep 120

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #E, AID: 5 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (false) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5

# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Winner Collect: Nobody,  AID: 5 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 5 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #E, AID: 5 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (false) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5


echo "========== # F, AID: 3 =========="

displayFUSD()

echo "---------- Auction Item, AID: 3 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 3

# F : MID 6, AID: 3
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #F, AID: 3 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 3 : 36.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 36.0 --signer nobody #F // increase time 60 seconds

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #F, AID: 3 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

sleep 120

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #F, AID: 3 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (false) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3 # Auction has ended.

# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Winner Collect: Nobody,  AID: 3 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CREATOR 3 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #F, AID: 3 =========="
echo "Minted New NFT #9, reprint restarts new auction, Casue: Winner Collect"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3 # New NFT #9
