// Transaction3.cdc

import Profile from 0xf8d6e0586b0a20c7
import DAAM    from 0xf8d6e0586b0a20c7

// This transaction configures a user's account to use the NFT contract by creating a new 
// empty collection, storing it in their account storage, and publishing a capability

transaction {  
    let address: Address  
    prepare(acct: AuthAccount) {
        self.address = acct.address
        let vault_name = "My D.A.A.M Vault"
        let collection_name = "My D.A.A.M Collection"

        // If No Profile, Create one        
        if !Profile.check(self.address) {
            acct.save(<- Profile.new(), to: Profile.privatePath)
            acct.link<&Profile.Base{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
            log("Created new Profile")
        }
        // add New Collection
        DAAM.addArtist(self.address)
        log("Added artist collection")
    }

    post { Profile.check(self.address): "Account was not initialized" }
}// transaction
