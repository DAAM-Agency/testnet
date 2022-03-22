# B ID: 2
# Testing Buy It Now
# Testing Time Left
echo "========== # B, AID: 2 =========="

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


echo "---------- Auction Item, AID: 2 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 2

echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Not Enough. AID: 2"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 2.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Did not meet Buy It Now: Too much. AID: 2"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 43.0 --signer client #I

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client AID: 2 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 2 30.2 --signer client #I

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========== Script: timeLeft.cdc Auction #B, AID: 2 =========="
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 2 (True due to reprint Series = true) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 2
