
#!/bin/bash

flow transactions send ./transactions/auction/close_all_auctions.cdc --signer $1 --gas-limit 9999 #emulator
LAST_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
CURRENT_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
echo "AuctionHouse Management Running..."
echo "Signer:" $1
echo "Press Ctrl-C to Quit"

while true; do
    sleep 1
	CURRENT_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
	echo $LAST_HEIGHT $CURRENT_HEIGHT
	if [ `expr $LAST_HEIGHT \< $CURRENT_HEIGHT` == 1 ]; then
		#AUCTIONS=$(flow -o json -n testnet events get A.01837e15023c9249.AuctionHouse.ItemWon --last $(expr $CURRENT_HEIGHT - $LAST_HEIGHT))  # testnet
		AUCTIONS=$(flow -o json events get A.045a1763c93006ca.AuctionHouse.ItemWon --last $(expr $CURRENT_HEIGHT - $LAST_HEIGHT))  # emulator
		echo inif Auctions=$AUCTIONS
		if [ $AUCTIONS != []  ]; then
			flow transactions send ./transactions/auction/close_all_auctions.cdc --signer $1 --gas-limit 9999 #emulator
		fi
		LAST_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
	fi
done