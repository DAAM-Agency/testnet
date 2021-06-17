# verify transactions

# Setup Profiles
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin
flow transactions send ./testnet/transactions/create_profile.cdc --signer admin2
flow transactions send ./testnet/transactions/create_profile.cdc --signer creator
flow transactions send ./testnet/transactions/create_profile.cdc --signer client
flow transactions send ./testnet/transactions/create_profile.cdc --signer nobody
flow transactions send ./testnet/transactions/create_profile.cdc --signer marketplace

# Setup DAAM Accounts
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer creator
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer client
flow transactions send ./testnet/transactions/setup_daam_account.cdc --signer admin2

# Invite Admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin

# Invite Creator & Accept
flow transactions send ./testnet/transactions/admin/invite_creator.cdc --arg Address:$CREATOR --signer admin
flow transactions send ./testnet/transactions/admin/invite_creator.cdc --arg Address:$MARKETPLACE --signer admin
flow transactions send ./testnet/transactions/answer_creator_invite.cdc --arg Bool:true --signer creator
flow transactions send ./testnet/transactions/answer_creator_invite.cdc --arg Bool:true --signer marketplace

# Invite Admin #2
flow transactions send ./testnet/transactions/admin/invite_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./testnet/transactions/answer_admin_invite.cdc --arg Bool:true --signer admin2

# Submit 2 Metadata: #1 Solo, #2 Series(of 2)
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --arg UInt64:1 --signer creator
flow transactions send ./testnet/transactions/creator/submit_nft.cdc --arg UInt64:2 --signer creator

# Approve the Metadatas
flow transactions send ./testnet/transactions/admin/change_metadata_status.cdc --arg UInt64:1 --arg Bool:true --signer admin
flow transactions send ./testnet/transactions/admin/change_metadata_status.cdc --arg UInt64:2 --arg Bool:true --signer admin2

# Request Royality
flow transactions send ./testnet/transactions/request/make_request.cdc --arg UInt64:1 --signer creator
flow transactions send ./testnet/transactions/request/answer_request.cdc --arg UInt64:1 --arg Bool:true --signer admin

flow transactions send ./testnet/transactions/request/make_request.cdc --arg UInt64:2 --signer creator
flow transactions send ./testnet/transactions/request/answer_request.cdc --arg UInt64:2 --arg Bool:true --signer admin

# Mint 4 NFTs
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg UInt64:1 --signer creator
flow transactions send ./testnet/transactions/creator/mint_nft.cdc --arg UInt64:2 --signer creator

# Change Copyright
flow transactions send ./testnet/transactions/admin/change_copyright.cdc --arg UInt64:1 --signer admin
flow transactions send ./testnet/transactions/admin/change_copyright.cdc --arg UInt64:2 --signer admin

# Marketplace Test #1; Sale: Create, Start, Stop
flow transactions send ./testnet/transactions/marketplace/create_start_sale.cdc --arg UInt64:1 --arg UFix64:1.1 --signer creator
flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:2.2 --signer creator
flow transactions send ./testnet/transactions/marketplace/stop_sale.cdc --arg UInt64:1 --signer creator
flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:1 --arg UFix64:1.11 --signer creator

# Marketplace Test #2; Purchase, Start Sale
flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:1.11 --signer client
flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:2 --arg UFix64:2.2  --signer client

# Marketplace Test #3; Purchase Series
#flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:3 --arg UFix64:3.3 --signer creator
#flow transactions send ./testnet/transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:3 --arg UFix64:3.3 --signer client

# Marketpalce Start New Sale & Change Price

flow transactions send ./testnet/transactions/marketplace/create_sale.cdc --signer client
flow transactions send ./testnet/transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:2.2 --signer client
flow transactions send ./testnet/transactions/marketplace/change_price.cdc --arg UInt64:2 --arg UFix64:3.8 --signer client

# Change Creator Status
flow transactions send ./testnet/transactions/admin/change_creator_status.cdc --arg Address:$CREATOR --arg Bool:false --signer admin2

# Remove Admin / Creator
flow transactions send ./testnet/transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./testnet/transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin2
flow transactions send ./testnet/transactions/admin/remove_creator.cdc --arg Address:$CREATOR --signer admin

# Transfer NFT
#flow transactions send ./testnet/transactions/transfer.cdc --arg Address:$NOBODY --arg UInt64:3 --signer client

#0xf8d6e0586b0a20c7