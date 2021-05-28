# verify transactions

# setup profiles
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin2
flow transactions send ./testnet/transactions/create_profile.cdc --signer creator
flow transactions send ./testnet/transactions/create_profile.cdc --signer client
sleep 1s

# set up daam accounts
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer creator
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer client
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer admin2
sleep 1s

# init admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin
sleep 1s

#invite Arist & accept
flow transactions send ./testnet/transactions/admin/invite_creator.cdc --arg Address:$CREATOR --signer admin
sleep 1s

flow transactions send ./testnet/transactions/answer_creator_invite.cdc --arg Bool:true --signer creator
sleep 1s

# invite new admin
flow transactions send ./testnet/transactions/admin/invite_admin.cdc --arg Address:$ADMIN2 --signer admin
sleep 1s
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin2
sleep 1s

# submit 4 NFTs
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --signer creator
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --signer creator
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --signer creator
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --signer creator


# mint 4 NFTs
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg Address:$CREATOR --arg UInt:3 --signer admin
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg Address:$CREATOR --arg UInt:2 --signer admin2
sleep 1s
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg Address:$CREATOR --arg UInt:1 --signer admin
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg Address:$CREATOR --arg UInt:0 --signer admin2

# transfer
flow transactions send ./testnet/transactions/transfer.cdc \
--arg Address:$NOBODY --arg UInt64:1 --signer creator
sleep 1s

flow transactions send ./testnet/transactions/transfer.cdc \
--arg Address:$NOBODY --arg UInt64:2 --signer creator
sleep 1s

# marketplace Test # 1
flow transactions send ./testnet/transactions/marketplace/create_sale.cdc --signer nobody
flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:1 --arg UFix64:1.1 --signer nobody
sleep 1s

flow transactions send ./testnet/transactions/marketplace/stop_sale.cdc --arg UInt64:1 --signer nobody
flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:2.2 --signer nobody
sleep 1s

# marketplace Test # 2
flow transactions send ./testnet/transactions/marketplace/create_start_sale.cdc --arg UInt64:3  --arg UFix64:3.3 --signer creator
flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$NOBODY --arg UInt64:2 --arg UFix64:2.2 --signer client
sleep 1s

# change / answer Commision setting // in answer_request --arg UInt8:0 = Change Royality
flow transactions send ./testnet/transactions/admin/request_change_royality.cdc --arg UInt64:3 --arg Address:$CREATOR --arg UFix64:0.18 --signer admin
flow transactions send ./testnet/transactions/creator/answer_request.cdc --arg Bool:true --arg UInt8:0 --arg UInt64:3 --signer creator
sleep 1s

# marketpalce change price
flow transactions send ./testnet/transactions/marketplace/change_price.cdc --arg UInt64:3 --arg UFix64:3.8 --signer creator

# change copyright
flow transactions send ./testnet/transactions/admin/change_copyright.cdc --arg UInt64:3 --signer admin

# change creator status
flow transactions send ./testnet/transactions/admin/change_creator_status.cdc --arg Address:$CREATOR --arg Bool:false --signer admin2

# remove admin creator
flow transactions send ./testnet/transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./testnet/transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin2

flow transactions send ./testnet/transactions/admin/remove_creator.cdc --arg Address:$CREATOR --signer admin

#0xf8d6e0586b0a20c7