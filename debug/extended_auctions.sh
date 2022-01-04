# Create Extended Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# Starts in 20 seconds
CURRENT_TIME=$(date +%s)
OFFSET=20.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "START: "$START

echo "========== Create Extended Auctions Tests I =========="

echo "Test Extended Auction A: Item Won, Item & Collected"
flow transactions send ./transactions/auction/create_original_auction.cdc 1 $START \
30.0 true 20.0 false 0.05 11.00 \
20.0 30.1 true --signer creator #A MID: 1, AID: 1  // Auction ID

echo "Test Extended Auction B: Item Won, Item not Collected"
flow transactions send ./transactions/auction/create_auction.cdc 1 $START \
30.0 true 20.0 true 1.0 \
12.00 25.0 30.2 --signer creator #AID: 8  // Auction ID

sleep 20
