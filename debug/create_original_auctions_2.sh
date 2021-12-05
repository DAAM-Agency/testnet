. ./debug/create_auction_wallet/original_auctions.sh
. ./debug/view_basic_data.sh

echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer admin #E Verfied

. ./debug/create_auction_wallet/original_auctions_buy_it_now.sh
. ./debug/view_basic_data.sh

