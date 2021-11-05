// setup_daam_account.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V4             from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_V4.Collection> (from: DAAM_V4.collectionStoragePath) != nil { return }        
        let collection <- DAAM_V4.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM_V4.collectionStoragePath) // save the new account
        // create a public capability for the collection
        acct.link<&{DAAM_V4.CollectionPublic}>(DAAM_V4.collectionPublicPath, target: DAAM_V4.collectionStoragePath)
        log("DAAM_V4.Account Created, you now have a Collection to store NFTs'")
    }
}
