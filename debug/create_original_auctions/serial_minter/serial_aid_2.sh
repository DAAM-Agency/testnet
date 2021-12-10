echo "---------- buyItNow (1): Nobody 30.2, AID: 2 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- buyItNow (2) Nobody 30.2, AID: 2 ----------"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: No more reprints. AID: 12"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 12 30.2 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Get Creator Auctions ---------"
flow scripts execute ./scripts/auction/get_auctions.cdc $CREATOR
