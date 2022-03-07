# Create Auction Tests
# TokenID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64,
# startingBid: UFix64, reserve: UFix64, buyNow: UFix64

# Start Bidding
# starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=20.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)

echo "========== Create Auctions I =========="
echo "---------- Client Sells All (4) -----------"

echo "---------- TokenID: 2 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 2 $START \
330.0 false 0.0 false 0.05 \
11.00 20.0 30.1 --signer client #AID: 8  // Auction ID

echo "---------- TokenID: 7 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 7 $START \
330.0 false 0.0 true 1.0 \
12.00 25.0 30.2 --signer client #AID: 9  // Auction ID

echo "---------- TokenID: 6 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 6 $START \
330.0 false 0.0 false 0.04 \
10.00 26.0 30.3 --signer client #AID: 10  // Auction ID

echo "---------- TokenID: 5 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 5 $START \
330.0 false 0.0 false 0.05 \
11.00 20.0 30.1 --signer client #AID: 11  // Auction ID

echo "---------- Nobody Sells All (5) -----------"
echo "---------- TokenID: 8 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 8 $START \
330.0 false 0.0 false 0.04 \
13.00 26.0 30.5 --signer nobody #AID: 12  // Auction ID

echo "---------- TokenID: 10 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 10 $START \
330.0 false 0.0 false 0.04 \
10.00 26.0 30.4 --signer nobody #AID: 13  // Auction ID

echo "---------- TokenID: 14 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 14 $START \
330.0 false 0.0 false 0.025 \
15.00 28.0 30.6 --signer nobody #AID: 14  // Auction ID

echo "---------- TokenID: 12 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 12 $START \
330.0 false 0.0 false 0.025 \
15.00 28.0 30.7 --signer nobody #AID: 15  // Auction ID

echo "---------- TokenID: 1 ---------- "
flow transactions send ./transactions/auction/create_auction.cdc 1 $START \
330.0 false 0.0 false 0.025 \
15.00 28.0 30.7 --signer nobody #AID: 16  // Auction ID
