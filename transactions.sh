# verify transactions

# Setup Profiles
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer nobody

# Setup DAAM Accounts
flow transactions send ./transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./transactions/setup_daam_account.cdc --signer creator
flow transactions send ./transactions/setup_daam_account.cdc --signer client
flow transactions send ./transactions/setup_daam_account.cdc --signer admin2

# Invite Creator & Accept
flow transactions send ./transactions/admin/invite_creator.cdc --arg Address:$CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc --arg Bool:true --signer creator

# Invite Admin #2
flow transactions send ./transactions/admin/invite_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc --arg Bool:true --signer admin2

# Submit 2 Metadata: #1 Solo, #2 Series(of 2)
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:1 --arg String:"data" --arg String:"thumbnail" --arg String:"file" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc --arg UInt64:2 --arg String:"data" --arg String:"thumbnail" --arg String:"file" --signer creator

# Approve the Metadatas
flow transactions send ./transactions/admin/change_metadata_status.cdc --arg UInt64:1 --arg Bool:true --signer admin
flow transactions send ./transactions/admin/change_metadata_status.cdc --arg UInt64:2 --arg Bool:true --signer admin2

# Request Royality
flow transactions send ./transactions/request/make_request.cdc --arg UInt64:2 --signer creator
flow transactions send ./transactions/admin/answer_request.cdc --arg UInt64:2 --arg Bool:true --signer admin
flow transactions send ./transactions/request/accept_default.cdc --arg UInt64:1 --signer creator
#flow transactions send ./transactions/request/make_request.cdc --arg UInt64:1 --signer creator
#flow transactions send ./transactions/admin/answer_request.cdc --arg UInt64:1 --arg Bool:true --signer admin

# Mint 4 NFTs
flow transactions send ./transactions/creator/mint_nft.cdc --arg UInt64:1 --signer creator
flow transactions send ./transactions/creator/mint_nft.cdc --arg UInt64:2 --signer creator
flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR

# Change Copyright
flow transactions send ./transactions/admin/change_copyright.cdc --arg UInt64:1 --arg Int:3 --signer admin
flow transactions send ./transactions/admin/change_copyright.cdc --arg UInt64:2 --arg Int:3 --signer admin

# Marketplace Test #1; Sale: Create, Start, Stop
flow transactions send ./transactions/marketplace/create_start_sale.cdc --arg UInt64:1 --arg UFix64:10.0 --signer creator
flow transactions send ./transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:20.0 --signer creator
flow transactions send ./transactions/marketplace/stop_sale.cdc --arg UInt64:1 --signer creator
flow transactions send ./transactions/marketplace/start_sale.cdc --arg UInt64:1 --arg UFix64:15.0 --signer creator

# Marketplace Test #2; Purchase, Start Sale
flow transactions send ./transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:1 --arg UFix64:15.0 --signer client
flow accounts get $CREATOR
flow accounts get $CLIENT
flow accounts get $AGENCY
flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR
flow scripts execute ./scripts/collecion.cdc --arg Address:$CLIENT

flow transactions send ./transactions/marketplace/create_start_sale.cdc --arg UInt64:1 --arg UFix64:40.0 --signer client
flow transactions send ./transactions/marketplace/purchase_nft.cdc --arg Address:$CLIENT --arg UInt64:1 --arg UFix64:40.0 --signer nobody
flow accounts get $CREATOR
flow accounts get $CLIENT
flow accounts get $AGENCY
flow accounts get $NOBODY
flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR
flow scripts execute ./scripts/collecion.cdc --arg Address:$CLIENT
flow scripts execute ./scripts/collecion.cdc --arg Address:$NOBODY

flow transactions send ./transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:2 --arg UFix64:20.0  --signer client
flow accounts get $CREATOR
flow accounts get $CLIENT
flow accounts get $AGENCY
flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR
flow scripts execute ./scripts/collecion.cdc --arg Address:$CLIENT
flow scripts execute ./scripts/collecion.cdc --arg Address:$NOBODY

# Marketplace Test #3; Purchase Series
flow transactions send ./transactions/marketplace/start_sale.cdc --arg UInt64:3 --arg UFix64:30.0 --signer creator
flow transactions send ./transactions/marketplace/purchase_nft.cdc --arg Address:$CREATOR --arg UInt64:3 --arg UFix64:30.0 --signer client
'''
flow accounts get $CREATOR
flow accounts get $CLIENT
flow accounts get $AGENCY
flow scripts execute ./scripts/collecion.cdc --arg Address:$CREATOR
flow scripts execute ./scripts/collecion.cdc --arg Address:$CLIENT
flow scripts execute ./scripts/collecion.cdc --arg Address:$NOBODY

# Marketpalce Start New Sale & Change Price
flow transactions send ./transactions/marketplace/start_sale.cdc --arg UInt64:2 --arg UFix64:40.0 --signer client
flow transactions send ./transactions/marketplace/change_price.cdc --arg UInt64:2 --arg UFix64:55.0 --signer client

# Change Creator Status
flow transactions send ./transactions/admin/change_creator_status.cdc --arg Address:$CREATOR --arg Bool:false --signer admin2

# Remove Admin / Creator
flow transactions send ./transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin
flow transactions send ./transactions/admin/remove_admin.cdc --arg Address:$ADMIN2 --signer admin2
flow transactions send ./transactions/admin/remove_creator.cdc --arg Address:$CREATOR --signer admin

# Transfer NFT
flow transactions send ./transactions/transfer.cdc --arg Address:$NOBODY --arg UInt64:3 --signer client

# Scripts
flow scripts execute ./scripts/CheckTokenData.cdc --arg Address:$CLIENT --arg UInt64:1
flow scripts execute ./scripts/CheckMarketplaceData.cdc --arg Address:$CLIENT

#0xf8d6e0586b0a20c7
