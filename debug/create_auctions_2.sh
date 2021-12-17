. ./debug/create_original_auctions/original_auctions.sh
. ./debug/view_basic_data.sh

echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc $DISAPPROVED_COPYRIGHT 3 --signer cto #E Verfied

. ./debug/create_original_auctions/original_auctions_buy_it_now.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_1.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_2.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_3.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_4.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_5.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_6.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/bids/bid_auction_7.sh
. ./debug/view_basic_data.sh

. ./debug/create_original_auctions/serial_minter//serial_aid_2.sh
. ./debug/view_basic_data.sh

. ./debug/withdraw.sh $CREATOR2 6
. ./debug/winner_collect.sh.sh $CREATOR2 6
