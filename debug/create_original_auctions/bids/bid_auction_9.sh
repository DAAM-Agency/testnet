# I AID: 8
# Testing Buy It Now with Bids.

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR2
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 9 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 9

echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9
echo "========== AID: 9 =========="

echo "---------- Auction Item, AID: 9 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 2.0 --signer cto

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 43.0 --signer cto

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CTO AID: 9 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 30.1 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9