. ./debug/view_basic_data.sh
. ./debug/create_auctions/client_auctions.sh

. ./debug/create_auctions/bids/bid_auction_8.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_9.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_10.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_11.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_12.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_13.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_14.sh
. ./debug/view_basic_data.sh

. ./debug/close_auctions.sh $CLIENT $NOBODY 

. ./debug/create_auctions/winner_collect_original.sh $CREATOR2 6
