// Transaction3.cdc

import Profile from 0xf8d6e0586b0a20c7
import DAAM             from 0xf8d6e0586b0a20c7

// This transaction configures a user's account to use the NFT contract by creating a new 
// empty collection, storing it in their account storage, and publishing a capability

transaction {
    
    prepare(acct: AuthAccount) {
        let vault_name = "My D.A.A.M Vault"
        let collection_name = "My D.A.A.M Collection"


        // If No Profile, Create one        
        if !Profile.check(acct.address) {
            acct.save(<- Profile.new(), to: Profile.privatePath)
            acct.link<&Profile.Base{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
        }
        let profileProfile.read(acct.address)
        // add New Collection
        DAAM.addArtist()
    }

    post {
            Profile.check(self.address): "Account was not initialized"
        }
        


        
     
         
            
        
        



        
        var vault <- DAAM.createVault(name: vault_name)
        log("Vault created for account setup")        
        vault.createCollection(name: collection_name) // Create a new empty collection
        acct.save<@DAAM.Vault>(<-vault, to: /storage/DAAM) // store the empty NFT Collection in account storage
        log("Collection created for account setup")
        
        // create a public capability for the Collection
        acct.link<&DAAM.Vault>(/public/DAAM, target: /storage/DAAM)
        log("Capability created")
    }
}
