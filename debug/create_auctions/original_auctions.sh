# Create Original Auction Tests
# isMetadta: true if Metadata false if NFT
# MID: UInt64 if isMetadata is true, otherwise is ID got NFT when isMetadata is false
# start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
# reserve: UFix64, buyNow: UFix64, reprintSeries: UInt64

# Start Bidding
# Starts in 30 seconds

OFFSET=30
START=$(echo $(expr $(date +%s) + $OFFSET).0)
echo "START: "$START

echo "========== Create Original Auctions Tests I =========="

echo "Test Auction A: Item Won, Item & Collected"
flow transactions send ./transactions/auction/create_auction.cdc --args-json '[
{"type": "Bool"  , "value": true},
{"type": "UInt64", "value": "1"},
{"type": "UFix64", "value": "'"$START"'"},
{"type": "UFix64", "value": "330.0"},
{"type": "Bool"  , "value": false},
{"type": "UFix64", "value": "0.0"},
{"type": "Bool"  , "value": false},
{"type": "UFix64", "value": "0.05"},
{"type": "UFix64", "value": "11.0"},
{"type": "UFix64", "value": "20.0"},
{"type": "UFix64", "value": "30.1"},
{"type": "Optional", "value": null}
]' --signer creator #A MID: 1, AID: 1  // Auction ID

echo "Test Auction B: Item Won, Item not Collected"
flow transactions send ./transactions/auction/create_auction.cdc --args-json '[
{"type": "Bool"  , "value": true},
{"type": "UInt64", "value": "2"},
{"type": "UFix64", "value": "'"$START"'"},
{"type": "UFix64", "value": "330.0"},
{"type": "Bool"  , "value": false},
{"type": "UFix64", "value": "0.0"},
{"type": "Bool"  , "value": true},
{"type": "UFix64", "value": "1.0"},
{"type": "UFix64", "value": "12.0"},
{"type": "UFix64", "value": "25.0"},
{"type": "UFix64", "value": "30.2"},
{"type": "Optional", "value": null}
]' --signer creator #B MID: 2, AID: 2

echo "FAIL TEST: Test Auction C Metadatanwas deleted by Creator. Does not exist."
flow transactions send ./transactions/auction/create_auction.cdc true $REMOVED_METADATA $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.3 1 --signer creator #C MID: 3

echo "FAIL TEST: Test Auction D, does not exist. Rejected by Admin. Metadata Removed"
flow transactions send ./transactions/auction/create_auction.cdc true $DISAPPROVED_METADATA $START \
330.0 false 0.0 false 0.04 10.00 \
26.0 30.4 1 --signer creator #D MID: 4

echo "FAIL TEST: Test Auction E, Rejected by Copyright Claim"
flow transactions send ./transactions/auction/create_auction.cdc true 5 $START \
330.0 false 0.0 false 0.04 13.00 \
26.0 30.5 1 --signer creator #E MID: 5

echo "Test Auction F: Item: Reserve not meet, Item returned."
flow transactions send ./transactions/auction/create_auction.cdc --args-json '[
{"type": "Bool"  , "value": true},
{"type": "UInt64", "value": "6"},
{"type": "UFix64", "value": "'"$START"'"},
{"type": "UFix64", "value": "330.0"},
{"type": "Bool"  , "value": false},
{"type": "UFix64", "value": "0.0"},
{"type": "Bool"  , "value": false},
{"type": "UFix64", "value": "0.05"},
{"type": "UFix64", "value": "14.0"},
{"type": "UFix64", "value": "27.0"},
{"type": "UFix64", "value": "30.3"},
{"type": "Optional", "value": null}
]' --signer creator2 #F, MID: 6, AID: 3

echo "Test Auction G: No Bids, Item returned."
flow transactions send ./transactions/auction/create_auction.cdc true 7 $START \
330.0 false 0.0 false 0.025 15.00 \
28.0 0.0 1 --signer creator2 #G, MID: 7, AID: 4, No Buy it now

echo "Test Auction H: No Bids, Item returned."
flow transactions send ./transactions/auction/create_auction.cdc true 8 $START \
330.0 false 0.0 false 0.025 15.00 \
28.0 0.0 1 --signer creator2 #H, MID: 8, AID: 5, No Buy it now


echo "Test Auction G: No Bids, Item returned."
flow transactions send ./transactions/auction/create_auction.cdc true 9 $START \
330.0 false 0.0 false 0.025 15.00 \
28.0 0.0 1 --signer creator2 #G, MID: 9, AID: 6, No Buy it now


# Auction Scripts
echo "========= Verify Auctions ========="
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2

sleep $OFFSET
