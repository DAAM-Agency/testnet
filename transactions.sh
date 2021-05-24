# verify transactions

# setup profiles
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin
flow transactions send ./testnet/transactions/create_profile.cdc --signer artist
flow transactions send ./testnet/transactions/create_profile.cdc --signer client
sleep 1s

# set up daam accounts
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer artist
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer client
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

# mint 4 NFTs
flow transactions send ./testnet/transactions/artist/mint_nft.cdc --signer artist
flow transactions send ./testnet/transactions/artist/mint_nft.cdc --signer artist
sleep 1s
flow transactions send ./testnet/transactions/artist/mint_nft.cdc --signer artist
flow transactions send ./testnet/transactions/artist/mint_nft.cdc --signer artist
sleep 1s

# transfer
flow transactions send ./testnet/transactions/transfer.cdc \
--arg Address:$NOBODY --arg UInt64:1 --signer artist
sleep 1s

flow transactions send ./testnet/transactions/transfer.cdc \
--arg Address:$NOBODY --arg UInt64:2 --signer artist
sleep 1s

# marketplace Test # 1
flow transactions send ./testnet/transactions/marketplace/create_sale.cdc --signer nobody
sleep 1s

flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:1 --arg UFix64:1.1 --signer nobody
sleep 1s

flow transactions send ./testnet/transactions/marketplace/stop_sale.cdc --arg UInt64:1 --signer nobody
sleep 1s

flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:2.2 --signer nobody
sleep 1s

# marketplace Test # 2
flow transactions send ./testnet/transactions/marketplace/create_start_sale.cdc --arg UInt64:3  --arg UFix64:3.3 --signer artist
sleep 1s

flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$NOBODY --arg UInt64:2 --arg UFix64:2.2 --signer client
sleep 1s

# change / answer Commision setting
flow transactions send ./testnet/transactions/admin/request_change_commission.cdc --arg UInt64:3 --arg Address:$ARTIST --arg UFix64:0.18 --signer admin
flow transactions send ./testnet/transactions/artist/answer_request.cdc --arg Bool:true --arg String:"Change Commission" --arg UInt64:3 --signer artist
sleep 1s

# marketpalce change price
flow transactions send ./testnet/transactions/marketplace/change_price.cdc --arg UInt64:3 --arg UFix64:3.8 --signer artist

#flow transactions send ./testnet/transactions/admin/change_receiver.cdc --arg UInt64:2 --arg UFix64:3.8 --signer admin

#0xf8d6e0586b0a20c7