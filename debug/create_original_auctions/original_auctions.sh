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

echo "========== Create Original Auctions Tests I =========="

echo "Test Auction A: Item Won, Item & Collected"
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
330.0 false 0.0 false 0.05 11.00 \
20.0 30.1 true --signer creator #A MID: 1, AID: 1  // Auction ID

echo "Test Auction B: Item Won, Item not Collected"
flow transactions send ./transactions/auction/create_original_auction.cdc 2 $START \
330.0 false 0.0 true 1.0 12.00 \
25.0 30.2 true --signer creator #B MID: 2, AID: 2

echo "FAIL TEST: Test Auction C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_original_auction.cdc 3 $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.3 false --signer creator #C MID: 3

echo "FAIL TEST: Test Auction D, does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_original_auction.cdc 4 $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.4 false --signer creator #D MID: 4

echo "FAIL TEST: Test Auction E, Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_original_auction.cdc 5 $START \
330.0 false 0.0 false 0.04 13.00 \
26.0 30.5 false --signer creator #E MID: 5

echo "Test Auction F: Item: Reserve not meet, Item returned."
flow transactions send ./transactions/auction/create_original_auction.cdc 6 $START \
330.0 false 0.0 false 0.05 14.00 \
27.0 30.3 true --signer creator #F, MID: 6, AID: 3

echo "Test Auction G: No Bids, Item returned."
flow transactions send ./transactions/auction/create_original_auction.cdc 7 $START \
330.0 false 0.0 false 0.025 15.00 \
28.0 0.0 false --signer creator #G, MID: 7, AID: 4

# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2
