# F AID: 3
# Also Testing Auction Status
echo "========= Cancel Auction AID: 3 ========="

echo "---------- Auction Item, AID: 3 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST:  Nobody makes the same bid too low. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 2.0 --signer nobody #F

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "--------- Cancel Auction: AID: 3 ---------"
flow transactions send ./transactions/auction/cancel_auction.cdc 3 --signer creator

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid: Client AID:3, 20.0 Auction already cancelled. AID: 3"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 3 20.0 --signer client #G

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 3 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 3

# G AID: 4
echo "========= Auction: # G, AID: 4  ========="
echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 4 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:4, 20.0"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 4 20.0 --signer client #G

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Bid made. Too late to Cancel Auction: AID: 4"
flow transactions send ./transactions/auction/cancel_auction.cdc 4 --signer creator

echo "FAIL TEST: Script: BuyItNow Creator, AID: 4"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CREATOR 4

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 4 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 4

# H : AID 6
# reserve price will be met and Collected
# test Withdraw
echo "========== # H, AID: 6 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 6 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 6

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:6 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 23.0 --signer client #H

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID:6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 20.0 --signer nobody #H // total 40

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 6, Client: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 6 30.0 --signer client #H // total 50

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 6 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 6

# I AID: 7
# Testing Buy It Now with Bids.
echo "========== # I, AID: 7 =========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 7 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 7

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 7 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 20.0 --signer nobody #I

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client ID:7 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 23.0 --signer client #I

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody ID:7 9.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 7 9.0 --signer nobody #E // total 29

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Buy It Now: Client ID: 7 ========="
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 7 7.7 --signer client #I 30.7

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: ID: 7 (False) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 7