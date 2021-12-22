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
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 14 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 14

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID: 14 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO ID:14 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 23.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:14 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 14 9.0 --signer client # total 29

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: CTO ID: 14 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $NOBODY 14 7.7 --signer cto # total 30.7

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 14 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 14