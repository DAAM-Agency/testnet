# AID: 15
# Testing Buy It Now with Bids.
echo "========== # AID: 15 =========="

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

echo "---------- Auction Item, AID: 15 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 15

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 AID: 15 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 20.0 --signer client

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 ID:15 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 23.0 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 ID:15 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 9.0 --signer client # total 29

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

echo "========= Buy It Now: CLIENT2 ID: 15 ========="

BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $NOBODY 15 $CLIENT2 | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 15 $BUYITNOW --signer client2 # total 30.7

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 15 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 15

echo "========= Auction Log: AID: 15 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $NOBODY 15