# verify transactions
flow transactions send ./testnet/transactions/setup_profile.cdc --signer admin
sleep 1s
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin
sleep 1s

flow transactions send ./testnet/transactions/setup_profile.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/add_artist.cdc --arg Address:$ARTIST --signer admin
sleep 1s  

flow transactions send ./testnet/transactions/mint_nft.cdc
#sleep 1s
#flow transactions send ./testnet/transactions/nft_exist.cdc
#sleep 1s
#flow transactions send ./testnet/transactions/setup_account.cdc --signer client
#sleep 1s
#flow transactions send ./testnet/transactions/transfer.cdc --arg Address: --arg UInt64:
#sleep 1s