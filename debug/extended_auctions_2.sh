displayFUSD()
{
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
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $AGENCY | jq -c ' .value | .value'
    echo "CTO FUSD"
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CTO | jq -c ' .value | .value'
}

# Create Original Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# Starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=30.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "START: "$START

#EXTENDED_TIME=[-n $1] && $1 || 0.0 # Conditional statement, add extended time otherwise extended time = 0.0
#IS_EXTENDED=[! -n $1] # if Extended Time is set, Set IS_EXTENDED = true

if [ -z "$1" ]; then # Conditional statement, add extended time otherwise extended time = 0.0
    EXTENDED_TIME=0.0
    IS_EXTENDED=false
else
    EXTENDED_TIME=$(echo $1' * 1.0' | bc)
    IS_EXTENDED=true    
fi

echo -n "EXTENDED_TIME: "; echo $EXTENDED_TIME
echo -n "EXTENDED: "; echo $IS_EXTENDED

echo "========== Create Extneded Auctions Tests I =========="

echo "Test Auction A: Item will be Won, Item & Collected"
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.05 11.00 \
20.0 30.1 true --signer creator #A MID: 1, AID: 1  // Auction ID

echo "Test Auction B: Item wil be Won, Item not Collected"
flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
330.0 $IS_EXTENDED $EXTENDED_TIME true 1.0 12.00 \
25.0 30.2 true --signer creator #B MID: 2, AID: 2

echo "FAIL TEST: Test Auction C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_original_auction.cdc $REMOVED_METADATA $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.04 10.00 \
26.0 30.3 false --signer creator #C MID: 3

echo "FAIL TEST: Test Auction D, does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_original_auction.cdc $DISAPPROVED_METADATA $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.04 10.00 \
26.0 30.4 false --signer creator #D MID: 4

echo "FAIL TEST: Test Auction E, Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.04 13.00 \
26.0 30.5 false --signer creator #E MID: 5

echo "Test Auction F: Item: Reserve not meet, Item returned."
flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.05 14.00 \
27.0 30.3 true --signer creator2 #F, MID: 6, AID: 3

echo "Test Auction G: No Bids, Item returned."
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
330.0 $IS_EXTENDED $EXTENDED_TIME false 0.025 15.00 \
28.0 0.0 false --signer creator2 #G, MID: 7, AID: 4, No Buy it now

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2

# ---------------------- BIDS ------------------------------

echo "========= BIDS ========="
sleep 20
# A ID: 1
# The reserve price will NOT be met.
echo "========== # A, AID: 1 =========="

displayFUSD

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
echo "Buy It Now: 30.1 Client."
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 1 30.1 --signer client #A

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1
# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to Creator at closr of auction.

echo "========== # B, AID: 2 =========="

displayFUSD

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

displayFUSD

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

displayFUSD

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
flow scripts execute ./scripts/auction_status.cdc $CREATOR 3 # Auction has ended.
