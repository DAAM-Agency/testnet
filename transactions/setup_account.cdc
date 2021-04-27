// Transaction3.cdc

import DAAM from 0xf8d6e0586b0a20c7
import NonFungibleToken from 0xf8d6e0586b0a20c7

// This transaction configures a user's account
// to use the NFT contract by creating a new empty collection,
// storing it in their account storage, and publishing a capability
transaction {
    prepare(acct: AuthAccount) {       
        let collection <- DAAM.createNewCollection(name: "") // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection>(<-collection, to: /storage/DAAMCollection) // store the empty NFT Collection in account storage
        log("Collection created for account")
        // create a public capability for the Collection
        acct.link<&DAAM.Collection>(/public/DAAMCollection, target: /storage/DAAMCollection)
        log("Capability created")
    }
}
 
