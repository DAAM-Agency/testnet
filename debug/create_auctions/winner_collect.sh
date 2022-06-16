# Winner Colection
echo "========= Winner Tests ========="
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT. AID: 10"
flow transactions send ./transactions/auction/winner_collect.cdc $CLIENT 10 --signer nobody --gas-limit 9999

echo "---------- Winner Collect: Cto, AID: 10 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $CLIENT 10 --signer cto --gas-limit 9999

echo "FAIL TEST: Script: BuyItNow Creator, AID: 10"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $CLIENT 10
