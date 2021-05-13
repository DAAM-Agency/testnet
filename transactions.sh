# verify transactions

# setup profiles
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin
sleep 1s
flow transactions send ./testnet/transactions/create_profile.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/create_profile.cdc --signer client
sleep 1s

# init admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin
sleep 1s

#invite Arist & accept
flow transactions send ./testnet/transactions/invite_artist.cdc --arg Address:$ARTIST --signer admin
sleep 1s
flow transactions send ./testnet/transactions/setup_account.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/answer_artist_invite.cdc --arg Bool:true --signer artist
sleep 1s

# invite new admin
flow transactions send ./testnet/transactions/invite_admin.cdc --arg Address:$CLIENT --signer admin
sleep 1s
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer client
sleep 1s

# mint nft
flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
sleep 1s

# receive nft
#flow transactions send ./testnet/transactions/setup_account.cdc --signer nobody
#sleep 1s
#flow transactions send ./testnet/transactions/transfer.cdc --arg Address:$NOBODY --arg UInt64:1 --signer marketpalace
#sleep 1s

#0xf8d6e0586b0a20c7