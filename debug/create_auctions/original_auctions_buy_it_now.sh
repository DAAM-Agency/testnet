# Create Original Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Start Bidding
# Create Original Auction Tests
# MID: UInt64, start: UFix64
# length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: Bool

# Starts in 30 seconds
CURRENT_TIME=$(date +%s)
OFFSET=30.0
START=$(echo "${CURRENT_TIME} + ${OFFSET}" |bc)
echo "START: "$START

echo "========== Create Original Auctions Tests II =========="
# Auction MID 5, AID: 5 after copyright adjustment. (set to Verfied)
echo "Test Auction E: Buy It Now"
flow transactions send ./transactions/auction/create_original_auction.cdc $DISAPPROVED_COPYRIGHT $START \
500.0 false 0.0 false 0.04 13.00 \
20.0 30.5 false --signer creator #E AID: 5

# Auction ID: 6, Winner and Collect
echo "Test Auction H: Bids followed by Buy It Now"
flow transactions send ./transactions/auction/create_original_auction.cdc 8 $START \
500.0 false 0.0 false 0.025 15.00 \
20.0 30.6 true --signer creator2 #H, AID: 6

# Auction ID: 7, Bid(s), but auction in finalized by a BuyItNow
echo "Test Auction I: Bids followed by Buy It Now"
flow transactions send ./transactions/auction/create_original_auction.cdc 9 $START \
500.0 false 0.0 false 0.025 15.00 \
20.0 30.7 true --signer creator2 #I, AID: 7