# verify transactions

# setup profiles
flow transactions send ./testnet/transactions/setup_profile.cdc --signer admin
sleep 1s
flow transactions send ./testnet/transactions/setup_profile.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/setup_profile.cdc --signer client

# init admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin
sleep 1s

#invite Arist & accept
flow transactions send ./testnet/transactions/invite_artist.cdc --arg Address:$ARTIST --signer admin
sleep 1s
flow transactions send ./testnet/transactions/answer_artist_invite.cdc --arg Bool:true --signer artist
sleep 2s

# invite new admin
flow transactions send ./testnet/transactions/invite_admin.cdc --arg Address:$CLIENT --signer admin
#sleep 3s
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer client


flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
#sleep 1s
#flow transactions send ./testnet/transactions/nft_exist.cdc
#sleep 1s
#flow transactions send ./testnet/transactions/setup_account.cdc --signer client
#sleep 1s
#flow transactions send ./testnet/transactions/transfer.cdc --arg Address: --arg UInt64:
#sleep 1s

#0xf8d6e0586b0a20c7