// Transaction3.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xf8d6e0586b0a20c7

// This transaction configures a user's account to use the NFT contract by creating a new 
// empty collection, storing it in their account storage, and publishing a capability

transaction {
    prepare(acct: AuthAccount) {       
        let collection <- DAAM.createNewCollection(name: "My Collection") // Create a new empty collection        
        acct.save<@NonFungibleToken.Collection>(<-collection, to: /storage/DAAMVault) // store the empty NFT Collection in account storage
        log("Collection created for account")
        // create a public capability for the Collection
        acct.link<&DAAM.Collection>(/public/DAAMVault, target: /storage/DAAMVault)
        log("Capability created")
    }
}
