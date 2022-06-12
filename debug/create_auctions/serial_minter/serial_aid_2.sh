echo "---------- buyItNow (1): Nobody 30.2, AID: 2 ----------"
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR 2 $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 $BUYITNOW --signer nobody #E

echo "NOBODY FUSD"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

echo "Time Left: "
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 2

echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

echo "---------- BuyItNow (2) Nobody, AID: 2 ----------"

BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR 2 $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 $BUYITNOW --signer nobody #E

echo "NOBODY FUSD"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

echo "FAIL TEST: No more reprints. AID: 12"
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR 2 $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 $BUYITNOW --signer nobody #E

echo "--------- Get Creator Auctions ---------"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
