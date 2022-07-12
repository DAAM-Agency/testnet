
flow transactions send transactions send ./transactions/auction/close_all_auctions.cdc --signer cto
FLOW_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
echo "Press Ctrl-Q to Quit"

do {
if FLOW_HEIGHT < $(flow -o json blocks get latest | jq -r ' .height') {
	DAAM_EVENTS=$(flow -o json events get A.01837e15023c9249.AuctionHouse.AuctionCreated --start FLOW_HEIGHT --end $(flow -o json blocks get latest | jq -r ' .height'))
	flow transactions send transactions send ./transactions/auction/close_all_auctions.cdc --signer cto
	FLOW_HEIGHT=$(flow -o json blocks get latest | jq -r ' .height')
} while(true)
