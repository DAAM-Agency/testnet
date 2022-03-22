echo "---------- FUSD ----------"
echo "CREATOR FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CREATOR | jq -c ' .value | .value'
echo "CREATOR2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CREATOR2 | jq -c ' .value | .value'
echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'
echo "CLIENT2 FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT2 | jq -c ' .value | .value'
echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'
echo "AGENCY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $AGENCY| jq -c ' .value | .value'
echo "CTO FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CTO| jq -c ' .value | .value'

echo "---------- Auction Item, AID: 1 ----------"
flow scripts execute ./scripts/auction/item_info.cdc $CREATOR 1

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: BID: Client, AID 1 : 10.99 too low"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 2 10.99 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Client :AID 1 : 11.0 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.0 --signer client #A

echo "CLIENT FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $CLIENT | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "---------- BID: Nobody :AID 1 : 30.1 ----------"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 30.1 --signer nobody #A

echo "NOBODY FUSD"
flow -o json scripts execute ./scripts/get_fusd_balance.cdc $NOBODY | jq -c ' .value | .value'

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Nobody bids twice. Already leader AID: 1."
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 11.01 --signer nobody #A

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Verify Buy It Now option is false. AID:1"
flow transactions send ./transactions/auction/deposit_bid.cdc $CREATOR 1 19.0 --signer client #A total: 30.0

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "========= Auction Status: AID: 1 (True) =========="
flow scripts execute ./scripts/auction/auction_status.cdc $CREATOR 1
# auction_status: nil=not started, true=ongoing, false=ended

# NFT will be sent back to Creator at closr of auction.