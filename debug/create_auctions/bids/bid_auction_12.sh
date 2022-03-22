# AID: 12
echo "========= AID: 12  ========="

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

echo "---------- Auction Item, AID: 12 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 AID: 12, 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 12 20.0 --signer client2

echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 12"
flow transactions send ./transactions/auction/cancel_auction.cdc 12 --signer nobody

echo "----------- Script: BuyItNow Creator, AID: 12 (false) ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 12 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 12