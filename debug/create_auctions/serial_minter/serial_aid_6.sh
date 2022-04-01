# Test Serial Minter
echo "========== Testing Serial Minter AID: 6 =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- buyItNow (1): Nobody AID: 6 ----------"
BUYITNOW=$(flow scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR2 6 $NOBODY | awk '{print $2}')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 $BUYITNOW --signer nobody #H

echo "NOBODY FUSD"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2

echo "========== Testing: endReprint =========="
flow transactions send ./transactions/auction/end_reprints.cdc 6 --signer creator2
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- BuyItNow (2) 30.6, Nobody AID: 6 ----------"

BUYITNOW=$(flow scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR2 6 $NOBODY | awk '{print $2}')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 $BUYITNOW --signer nobody #H

echo "FAIL TEST: No more reprints due to endReprint (previous) AID: 6"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 30.6 --signer nobody #H
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2