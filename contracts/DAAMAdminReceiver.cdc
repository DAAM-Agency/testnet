// DAAM, // Ami Rajpal
// Based on TopShots
// https://github.com/dapperlabs/nba-smart-contracts/blob/master/contracts/TopShotAdminReceiver.cdc

/*
  AdminReceiver.cdc
  This contract defines a function that takes a DAAM Admin object and stores it in the storage of the contract account
  so it can be used.
 */

import DAAM from 0xf8d6e0586b0a20c7
import NonFungibleToken from 0xf8d6e0586b0a20c7

pub contract DAAMAdminReceiver {
    access(self) var vaultIDCounter: UInt64
    pub fun storeAdmin(newAdmin: @DAAM.Admin) { self.account.save<@DAAM.Admin>(<-newAdmin, to: /storage/DAAMAdmin) }
    
    init() {
        let vault_name = "The D.A.A.M Vault"
        let collection_name = "The D.A.A.M Collection"
        self.vaultIDCounter = 0  // Initialize Vault counter acts as increamental serial number

        var collection <- DAAM.createNewCollection(name: collection_name)  // Put a new Collection in storage
        var daam <- create Vault(name: vault_name)
        daam.vault[daam.name] <-! collection
        
        self.account.save<@Vault>(<-daam, to: /storage/DAAMVault)
        self.account.link<&Vault>(/public/DAAMVault, target: /storage/DAAMVault)                
    }
    /************************************************************/
    pub resource Vault {
        pub let name: String
        pub let id: UInt64
        pub var vault: @{String: NonFungibleToken.Collection}

        init(name: String) {
            DAAMAdminReceiver.vaultIDCounter = 0
            self.name = name
            self.id = DAAMAdminReceiver.vaultIDCounter
            DAAMAdminReceiver.vaultIDCounter = DAAMAdminReceiver.vaultIDCounter + 1 as UInt64
            self.vault <- {}
        }

        destroy() { destroy self.vault } // TODO SHOULD IT BE MOVED INSTEAD, USING DEFAULT
    }
}
