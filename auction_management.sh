
#!/bin/bash

flow transactions send $1 $2/transactions/auction/close_all_auctions.cdc --signer $3 --gas-limit 9999 #emulator
LAST_HEIGHT=$(flow -o json $1 blocks get latest | jq -r ' .height')
CURRENT_HEIGHT=$(flow -o json $1 blocks get latest | jq -r ' .height')
echo "AuctionHouse Management Running..."
echo "Signer:" $3
echo "Press Ctrl-C to Quit"

while true; do
    sleep 1
	CURRENT_HEIGHT=$(flow -o json $1 blocks get latest | jq -r ' .height')
	echo $LAST_HEIGHT $CURRENT_HEIGHT
	if [ `expr $LAST_HEIGHT \< $CURRENT_HEIGHT` == 1 ]; then
		AUCTIONS=$(flow -o json $1 events get A.01837e15023c9249.AuctionHouse.ItemWon --last $(expr $CURRENT_HEIGHT - $LAST_HEIGHT))  # emulator
		echo init Auctions=$AUCTIONS
		if [ $AUCTIONS != []  ]; then
			flow transactions send $1 $2/transactions/auction/close_all_auctions.cdc --signer $3 --gas-limit 9999 #emulator
		fi
		LAST_HEIGHT=$(flow -o json $1 blocks get latest | jq -r ' .height')
	fi
done