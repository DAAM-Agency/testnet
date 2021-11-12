// setup_daam_account.cdc
// Create A DAAM_V6 Wallet to store DAAM_V6 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V6             from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_V6.Collection> (from: DAAM_V6.collectionStoragePath) != nil { return }        
        let collection <- DAAM_V6.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM_V6.collectionStoragePath) // save the new account
        acct.link<&{DAAM_V6.CollectionPublic}>(DAAM_V6.collectionPublicPath, target: DAAM_V6.collectionStoragePath)
        log("DAAM_V6 Account Created, you now have a Collection to store NFTs'")
    }
}
