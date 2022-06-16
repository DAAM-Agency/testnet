echo "========= Close Auctions ========="
for user do
  flow transactions send ./transactions/auction/close_auctions.cdc $user --gas-limit 9999 --signer cto --gas-limit 9999
done
