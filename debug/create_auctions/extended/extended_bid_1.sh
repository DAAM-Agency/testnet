flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "---------- Auction Item, AID: 1 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 1
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

echo "---------- Auction Time Left ------------"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 1

echo "---------- BID: Client, AID 1: 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client ##Total: 11.0

sleep 20

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody, AID 1: 14.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 14.1 --signer nobody #Total: 14.1

sleep 20

echo "---------- Auction Time Left ------------"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 1

echo "---------- BID: Client, AID 1: 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client #Total: 22.0

echo "---------- Auction Time Left ------------"
flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 1

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status, AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1

# Auction Status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to Creator at closr of auction.