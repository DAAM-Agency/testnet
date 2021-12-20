# Test Serial Minter
echo "========== Testing Serial Minter AID: 6 =========="

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (1): Nobody AID: 6 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 30.6 --signer nobody #H

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (2) 30.6, Nobody AID: 6 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Testing: endReprint =========="
flow transactions send ./transactions/auction/end_reprints.cdc 6 --signer creator2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints due to endReprint (previous) AID: 6"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR2 6 30.6 --signer nobody #H

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR2