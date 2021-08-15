// setup_daam_account.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V3.V2             from 0xa4ad5ea5c0bd2fba

// This transaction is what an account would run to set itself up to receive NFTs
transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM_V3.Collection> (from: DAAM_V3.collectionStoragePath) != nil { return }        
        let collection <- DAAM_V3.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM_V3.collectionStoragePath) // save the new account
        // create a public capability for the collection
        acct.link<&{DAAM_V3.CollectionPublic}>(DAAM_V3.collectionPublicPath, target: DAAM_V3.collectionStoragePath)
        log("DAAM_V3.Account Created, you now have a Collection to store NFTs'")
    }
}
