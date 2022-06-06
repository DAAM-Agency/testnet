aid=6

# Test Serial Minter
echo "========== Testing Serial Minter AID: "$aid" =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- BuyItNow Count: 1, Bidder: Nobody, AID: "$aid" ----------"
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR2 $aid $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 $aid $BUYITNOW --signer nobody #H

echo "NOBODY FUSD"
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2

echo "========== Testing: endReprint =========="
flow transactions send ./transactions/auction/end_reprints.cdc $aid --signer creator2
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- BuyItNow Count: 2, Bidder: Nobody, AID: "$aid" ----------"
BUYITNOW=$(flow -o json scripts execute ./scripts/auction/get_buy_now_amount.cdc $CREATOR2 $aid $NOBODY | jq -r ' .value ')
echo BUYITNOW: $BUYITNOW
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 $aid $BUYITNOW --signer nobody #H

echo "FAIL TEST: No more reprints due to endReprint (previous) AID: "$aid
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 $aid 30.$aid --signer nobody #H
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2