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

# AID: 12
echo "========= AID: 12  ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 12 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: CTO AID: 12, 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $NOBODY 12 20.0 --signer cto

echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 12"
flow transactions send ./transactions/auction/cancel_auction.cdc 12 --signer nobody

echo "----------- Script: BuyItNow Creator, AID: 12 (false) ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $NOBODY 12

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 12 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $NOBODY 12