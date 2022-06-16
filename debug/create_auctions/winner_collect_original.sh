# Winner Colection
echo "========= Winner Tests ========="

echo "Script: timeLeft.cdc Auction #F, AID: 6"
sleep $(flow -o json scripts execute ./scripts/auction/time_left.cdc $CREATOR 2 | jq -r ' .value | .value ')
sleep 20

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

echo "FAIL TEST: Wrong Bidder attempting to collect NFT. AID: 6"
flow transactions send ./transactions/auction/winner_collect.cdc $1 $2 --signer nobody --gas-limit 9999

echo "---------- Winner Collect: Client, #F AID: 6 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $1 $2 --signer client --gas-limit 9999

echo "----------- Script: BuyItNow Creator, AID: 6 (false) no more reprints ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $1 $2