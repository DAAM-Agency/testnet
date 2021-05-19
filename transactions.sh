# verify transactions

# setup profiles
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin
sleep 1s
flow transactions send ./testnet/transactions/create_profile.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/create_profile.cdc --signer client
sleep 1s

# set up daam accounts
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer nobody
sleep 1s
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer artist
sleep 1s

# init admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin
sleep 1s

#invite Arist & accept
flow transactions send ./testnet/transactions/admin/invite_artist.cdc --arg Address:$ARTIST --signer admin
sleep 1s

flow transactions send ./testnet/transactions/answer_artist_invite.cdc --arg Bool:true --signer artist
sleep 1s

# invite new admin
flow transactions send ./testnet/transactions/admin/invite_admin.cdc --arg Address:$CLIENT --signer admin
sleep 1s
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer client
sleep 1s

# mint 4 NFTs hhh
flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/mint_nft.cdc --signer artist
sleep 1s

# transfer
flow transactions send ./testnet/transactions/transfer.cdc \
--arg Address:$NOBODY --arg UInt64:2 --signer artist
sleep 1s

# marketplace
#flow transactions send ./testnet/transactions/marketplace2/create_sale_collection.cdc --arg UInt64:1 --arg UFix64:4.0 --signer artist
sleep 1s

# marketplace purchash, 
#flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$ARTIST --arg UInt64:1 --arg UFix64:5.0 --signer nobody

#0xf8d6e0586b0a20c7