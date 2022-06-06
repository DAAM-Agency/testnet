echo "========= Cancel Auction AID: 11 ========="

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

echo "---------- Auction Item, AID: 11 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 11

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 11 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 11

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low. AID: 11"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 11 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 11 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 11 --signer client

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 11 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 11

echo "========= Auction Log: AID: 11 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CLIENT 11