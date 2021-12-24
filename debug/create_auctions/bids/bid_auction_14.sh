# AID: 14
# Testing Buy It Now with Bids.
echo "========== # AID: 14 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

echo "---------- Auction Item, AID: 14 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 14

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 AID: 14 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CLIENT2 ID:14 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 23.0 --signer client2

echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client2 ID:14 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 9.0 --signer client # total 29

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CLIENT2 ID: 14 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 14 7.6 --signer client2 # total 30.7

echo "CLIENT2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 14 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 14