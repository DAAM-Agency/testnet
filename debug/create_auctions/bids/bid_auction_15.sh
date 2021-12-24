# AID: 15
# Testing Buy It Now with Bids.
echo "========== # AID: 15 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

echo "---------- Auction Item, AID: 15 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 15

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID: 15 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 ID:15 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 23.0 --signer client2

echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:15 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 15 9.0 --signer client # total 29

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CLIENT2 ID: 15 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 15 7.7 --signer client2 # total 30.7

echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 15 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 15