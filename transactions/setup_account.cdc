// Transaction3.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xf8d6e0586b0a20c7

// This transaction configures a user's account to use the NFT contract by creating a new 
// empty collection, storing it in their account storage, and publishing a capability

transaction {
    prepare(acct: AuthAccount) {
        let vault_name = "My D.A.A.M Vault"
        let collection_name = "My D.A.A.M Collection"
        
        var vault <- DAAM.createVault(name: vault_name)
        log("Vault created for account")        
        vault.createCollection(name: collection_name) // Create a new empty collection
        acct.save<@DAAM.Vault>(<-vault, to: /storage/My_DAAM_Vault) // store the empty NFT Collection in account storage
        log("Collection created for account")
        
        // create a public capability for the Collection
        acct.link<&DAAM.Vault>(/public/My_DAAM_Vault, target: /storage/My_DAAM_Vault)
        log("Capability created")
    }
}
