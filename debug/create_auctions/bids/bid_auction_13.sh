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

# AID 13
# reserve price will be met and Collected
# test Withdraw
echo "========== # AID: 13 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 13 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 13

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID: 13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO AID:13 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 23.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:13 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 20.0 --signer client # total 40

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 13, CTO: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 13 30.0 --signer cto # total 50