. ./debug/create_auctions/original_auctions.sh
. ./debug/view_basic_data.sh

echo "========= Reset Copyright ========="
flow transactions send ./transactions/admin/change_copyright.cdc $DISAPPROVED_COPYRIGHT 3 --signer cto #E Verfied

. ./debug/create_auctions/original_auctions_buy_it_now.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_1.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_2.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_3.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_4.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_5.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_6.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/bids/bid_auction_7.sh
. ./debug/view_basic_data.sh

flow scripts execute ./scripts/auction/time_left.cdc $CREATOR 2
. ./debug/create_auctions/serial_minter/serial_aid_2.sh
. ./debug/view_basic_data.sh

. ./debug/create_auctions/withdraw_original_auctions.sh $CREATOR2 6

# Wait for Auctions to Expire
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
TIME_LEFT=$(flow scripts execute ./scripts/auction/time_left.cdc $CREATOR2 6 | awk  '{print $2}')
echo "Time Left: $TIME_LEFT"
sleep $TIME_LEFT
sleep 20
TIME_LEFT=0
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc

. ./debug/create_auctions/winner_collect_original.sh $CREATOR2 6
. ./debug/close_auctions.sh creator creator2

flow scripts execute ./scripts/auction/time_left.cdc $CREATOR2 6
. ./debug/create_auctions/serial_minter/serial_aid_6.sh
. ./debug/view_basic_data.sh
