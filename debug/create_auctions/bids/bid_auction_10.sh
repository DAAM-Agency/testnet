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

# reserve price will be met
echo "========= AID: 10 ========="

echo "---------- Auction Item, AID: 10 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 10


flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 10 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 13.0 --signer nobody

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client2 :AID: 10 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 23.0 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- BID: Nobody AID: 10 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 17.0 --signer nobody # total 30

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client2 AID: 10 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 12.0 --signer client2 # total 35

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

echo "FAIL TEST: Nobody makes the same bid too late. AID: 10"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 5.0 --signer nobody
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "FAIL TEST: Buy It Now: too late.  AID: 10"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 10 30.0 --signer nobody
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "========= Auction Status: AID: 10 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 10
# NFT will be sent to Winner.

echo "========= Auction Log: AID: 10 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CLIENT 10