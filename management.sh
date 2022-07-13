
#!/bin/bash

flow transactions send ./transactions/auction/close_all_auctions.cdc --signer cto
LAST_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
CURRENT_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
echo "Press Ctrl-C to Quit"

while true; do
	CURRENT_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
	if [ `expr $LAST_HEIGHT \< $CURRENT_HEIGHT` == 1 ]; then
		echo "in if"
		#flow -o json events get A.01837e15023c9249.AuctionHouse.AuctionCreated --last $(expr $CURRENT_HEIGHT - $LAST_HEIGHT) # testnet
		AUCTIONS=$(flow events get A.045a1763c93006ca.AuctionHouse.AuctionCreated --last $(expr $CURRENT_HEIGHT - $LAST_HEIGHT))  # emulator
		echo Auctions=$AUCTIONS
		if [ -z $AUCTIONS  ]; then
			echo "GOAL"
			#flow transactions send transactions send ./transactions/auction/close_all_auctions.cdc --signer cto
		fi
		LAST_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
	fi
done