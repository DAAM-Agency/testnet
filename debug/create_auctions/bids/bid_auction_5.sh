# E : MID 5, AID: 5
# reserve price will be met
echo "========= Bid: Nobody AID: 5 11.0 ========="

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

echo "---------- Auction Item, AID: 5 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 13.0 --signer nobody #E

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 5 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 23.0 --signer client #E

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 17.0 --signer nobody #E // total 30

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 5 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 12.0 --signer client #E // total 35

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc  // total 35
echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

echo "FAIL TEST: Nobody makes the same bid too late. AID: 5"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 5.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late. AID: 5"
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR 5 $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 $BUYITNOW --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5
# NFT will be sent to Winner.

echo "========= Auction Log: AID: 5 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CREATOR 5