# verify transactions
flow transactions send ./testnet/transactions/setup_profile.cdc --signer artist
flow transactions send ./testnet/transactions/add_artist.cdc --arg Address:$ARTIST
flow transactions send ./testnet/transactions/mint_nft.cdc
flow transactions send ./testnet/transactions/nft_exist.cdc
flow transactions send ./testnet/transactions/setup_account.cdc --signer client
flow transactions send ./testnet/transactions/transfer.cdc --arg Address: --arg UInt64: