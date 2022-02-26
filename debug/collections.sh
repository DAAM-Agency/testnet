flow transactions send ./transactions/collections/create_collection.cdc "clients favs" --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT
   
flow transactions send ./transactions/collections/add_to_collection.cdc "clients favs" 2 --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT
   
flow transactions send ./transactions/collections/add_to_collection.cdc "clients favs" 5 --signer client
flow transactions send ./transactions/collections/add_to_collection.cdc "clients favs" 6 --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT
   
flow transactions send ./transactions/collections/remove_from_collection.cdc "clients favs" 6 --signer client
   
flow transactions send ./transactions/collections/create_collection.cdc "family" --signer client
flow transactions send ./transactions/collections/remove_collection.cdc "family" --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT

flow transactions send ./transactions/collections/create_collection.cdc "family" --signer client
flow transactions send ./transactions/collections/add_to_collection.cdc "family" 6 --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT
   
flow transactions send ./transactions/collections/remove_from_collections.cdc 6 --signer client
flow scripts execute ./scripts/daam_wallet/get_collections.cdc $CLIENT
