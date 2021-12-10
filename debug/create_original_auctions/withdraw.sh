# Withdraw
echo "========== Withdraw =========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Client can not withdraw bid, is leader. AID: 6"
flow transactions send ./transactions/auction/withdraw_bid.cdc $1 $2 --signer client #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Withdraw ----------"
flow transactions send ./transactions/auction/withdraw_bid.cdc $1 $2 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody can not withdraw bid a 2nd time. AID: 6"
flow transactions send ./transactions/auction/withdraw_bid.cdc $1 $2 --signer nobody #E