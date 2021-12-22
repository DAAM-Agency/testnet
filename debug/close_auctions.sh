echo "========= Close Auctions ========="
for user do
  flow transactions send ./transactions/auction/close_auctions.cdc --gas-limit 9999 --signer $user
done
