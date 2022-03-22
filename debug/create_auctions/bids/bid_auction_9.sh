# I AID: 8
# Testing Buy It Now with Bids.

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

echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9

echo "========== AID: 9 =========="

echo "---------- Auction Item, AID: 9 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 2.0 --signer client2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much. AID: 9"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 43.0 --signer client2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client2 AID: 9 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 9 30.2 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc AID: 9 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 9

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 9 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 9