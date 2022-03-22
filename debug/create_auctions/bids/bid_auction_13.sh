# I AID: 8
# Testing Buy It Now with Bids.

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

# AID 13
# reserve price will be met and Collected
# test Withdraw
echo "========== # AID: 13 =========="

echo "---------- Auction Item, AID: 13 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 13

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 AID: 13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 AID:13 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 23.0 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 AID:13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client # total 40

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 13, CLIENT2: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 30.0 --signer client2 # total 50