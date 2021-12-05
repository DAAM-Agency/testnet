# E : MID 5, AID: 5
# reserve price will be met
echo "========= Bid: Nobody AID: 5 11.0 ========="

echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 5 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 5

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 13.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 13.0 --signer nobody #E

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID: 5 : 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 23.0 --signer client #E

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody AID: 5 : 17.0 more ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 17.0 --signer nobody #E // total 30

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client AID: 5 : 12.0 more----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 12.0 --signer client #E // total 35

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc  // total 35
echo "FAIL TEST: Nobody makes the same bid too late. AID: 5"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 5 5.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Buy It Now: too late. AID: 5"
flow transactions send ./transactions/auction/buy_it_now.cdc $CREATOR 5 30.0 --signer nobody #E

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 5 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 5

# NFT will be sent to Winner.