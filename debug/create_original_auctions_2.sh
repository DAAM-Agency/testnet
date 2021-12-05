. ./debug/create_original_auctions/original_auctions.sh
. ./debug/view_basic_data.sh

echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc 5 3 --signer cto #E Verfied

. ./debug/create_original_auctions/original_auctions_buy_it_now.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bid_auction_1.sh
. ./debug/create_original_auctions/bid_auction_2.sh
. ./debug/create_original_auctions/bid_auction_3.sh
. ./debug/create_original_auctions/bid_auction_4.sh
. ./debug/create_original_auctions/bid_auction_5.sh
. ./debug/create_original_auctions/bid_auction_6.sh