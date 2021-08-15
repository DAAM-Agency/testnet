// setup_daam_account.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V2.V2             from 0xa4ad5ea5c0bd2fba

// This transaction is what an account would run to set itself up to receive NFTs
transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_V2.Collection> (from: DAAM_V2.collectionStoragePath) != nil { return }        
        let collection <- DAAM_V2.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM_V2.collectionStoragePath) // save the new account
        // create a public capability for the collection
        acct.link<&{DAAM_V2.CollectionPublic}>(DAAM_V2.collectionPublicPath, target: DAAM_V2.collectionStoragePath)
        log("DAAM_V2.Account Created, you now have a Collection to store NFTs'")
    }
}
