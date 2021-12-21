# I AID: 8
# Testing Buy It Now with Bids.

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR2
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

# reserve price will be met
echo "========= AID: 10 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 10 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CLIENT 10


flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 10 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 13.0 --signer nobody

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 10 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 23.0 --signer cto

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- BID: Nobody AID: 10 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 17.0 --signer nobody # total 30

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 10 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 12.0 --signer cto # total 35

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody makes the same bid too late. AID: 10"
flow transactions send ./transactions/auction/deposit_bid.cdc $CLIENT 10 5.0 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late.  AID: 10"
flow transactions send ./transactions/auction/buy_it_now.cdc $CLIENT 10 30.0 --signer nobody

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 10 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CLIENT 10

# NFT will be sent to Winner.