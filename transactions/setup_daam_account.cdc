// setup_daam_account.cdc
// Create A DAAM_V7 Wallet to store DAAM_V7 NFTs

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V7             from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_V7.Collection> (from: DAAM_V7.collectionStoragePath) != nil { return }        
        let collection <- DAAM_V7.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM_V7.collectionStoragePath) // save the new account
        acct.link<&{DAAM_V7.CollectionPublic}>(DAAM_V7.collectionPublicPath, target: DAAM_V7.collectionStoragePath)
        log("DAAM_V7 Account Created, you now have a Collection to store NFTs'")
    }
}
