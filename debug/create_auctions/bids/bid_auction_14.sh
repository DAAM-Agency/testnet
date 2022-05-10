# AID: 14
# Testing Buy It Now with Bids.
echo "========== # AID: 14 =========="

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

echo "---------- Auction Item, AID: 14 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 14

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 AID: 14 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 20.0 --signer client

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 ID:14 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 23.0 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 ID:14 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 9.0 --signer client # total 29

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

echo "========= Buy It Now: CLIENT2 ID: 14 ========="

BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $NOBODY 14 $CLIENT2 | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 14 $BUYITNOW --signer client2 # total 30.7

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 14 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 14

echo "========= Auction Log: AID: 14 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $NOBODY 14