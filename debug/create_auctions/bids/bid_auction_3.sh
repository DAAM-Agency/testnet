# F AID: 3
# Also Testing Auction Status
echo "========= Cancel Auction AID: 3 ========="

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

echo "---------- Auction Item, AID: 3 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR2 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR2 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 3 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 3 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 3 --signer creator2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid: Client AID:3, 20.0 Auction already cancelled. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 3 20.0 --signer client #G

echo "========= Auction Log: AID: 3 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CREATOR2 3