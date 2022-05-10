# I AID: 7
# Testing Buy It Now with Bids.
echo "========== # I, AID: 7 =========="

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

echo "---------- Auction Item, AID: 7 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR2 7

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 7 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 7 20.0 --signer nobody #I

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:7 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 7 23.0 --signer client #I

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:7 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 7 9.0 --signer nobody #E // total 29

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

echo "========= Buy It Now: Client ID: 7 ========="
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR2 7 $CLIENT | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 7 $BUYITNOW --signer client #I 30.7

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 7 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR2 7

echo "========= Auction Log: AID: 7 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CREATOR2 7