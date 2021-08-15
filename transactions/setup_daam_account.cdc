// setup_daam_account.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM             from 0xa4ad5ea5c0bd2fba

// This transaction is what an account would run to set itself up to receive NFTs
transaction()
{
    prepare(acct: AuthAccount) {
        // Return early if the account already has a collection
        if acct.borrow<&DAAM.Collection> (from: DAAM.collectionStoragePath) != nil { return }        
        let collection <- DAAM.createEmptyCollection()    // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM.collectionStoragePath) // save the new account
        // create a public capability for the collection
        acct.link<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
        log("DAAM Account Created, you now have a Collection to store NFTs'")
    }
}// transaction
