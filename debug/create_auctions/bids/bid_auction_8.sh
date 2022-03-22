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

echo "========== # A, AID: 8 =========="
echo "---------- Auction Item, AID: 8 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 8
flow scripts execute ./scripts/auction/time_left.cdc $CLIENT 8

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client, AID 8 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID 8 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.0 --signer cto #A

echo "CTO FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CTO | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :AID 8 : 30.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 30.1 --signer nobody #A

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader. AID: 8"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false. AID: 8"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 8 19.0 --signer cto #A total: 30.0

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 8 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 8
