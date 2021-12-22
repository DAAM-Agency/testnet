# H : AID 6
# reserve price will be met and Collected
# test Withdraw
echo "========== # H, AID: 6 =========="

echo "---------- FUSD ----------"
echo "CREATOR2 FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CREATOR2
echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT
echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY
echo "CTO FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CTO

echo "---------- Auction Item, AID: 6 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR2 6

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID: 6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 6 20.0 --signer nobody #H

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Client AID:6 23.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 6 23.0 --signer client #H

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: Nobody AID:6 20.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 6 20.0 --signer nobody #H // total 40

echo "NOBODY FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $NOBODY

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- Bid: AID 6, Client: 30.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR2 6 30.0 --signer client #H // total 50

echo "CLIENT FUSD"
flow scripts execute ./scripts/get_fusd_balance.cdc $CLIENT

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 6 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR2 6
