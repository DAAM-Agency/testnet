# G AID: 4
echo "========= Auction: # G, AID: 4  ========="

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

echo "---------- Auction Item, AID: 4 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR2 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:4, 20.0"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 4 20.0 --signer client #G

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 4"
flow transactions send ./transactions/auction/cancel_auction.cdc 4 --signer creator

echo "FAIL TEST: Script: BuyItNow Creator, AID: 4"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR2 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 4 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR2 4

echo "========= Auction Log: AID: 4 =========="
flow scripts execute ./scripts/auction/get_auction_log.cdc $CREATOR2 4