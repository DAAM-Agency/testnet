# Winner Colection
echo "========= Winner Tests ========="

echo "Script: timeLeft.cdc Auction #H, AID: 6"
flow scripts execute ./scripts/auction/time_left.cdc $1 $2

flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
echo "FAIL TEST: Wrong Bidder attempting to collect NFT. AID: 6"
flow transactions send ./transactions/auction/winner_collect.cdc $1 $2 --signer nobody

echo "---------- Winner Collect: Client, #G AID: 6 ----------"
flow transactions send ./transactions/auction/winner_collect.cdc $1 $2 --signer client

echo "----------- Script: BuyItNow Creator, AID: 6 (false) no more reprints ----------"
flow scripts execute ./scripts/auction/buy_it_now_status.cdc $1 $2