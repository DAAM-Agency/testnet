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
            self.vaultIDCounter      = 0  // Initialize Vault counter acts as increamental serial number
            let collection_name = "D.A.A.M Collection"
            let collection <- DAAM.createEmptyCollection()  // Put a new Collection in storage
            let vault <- create Vault(name: "D.A.A.M Vault", collection: <- collection, collection_name: collection_name)
            self.account.save<@Vault>(<-vault, to: /storage/DAAMVault)
            self.account.link<&Vault>(/public/DAAMVault, target: /storage/DAAMVault)                
    }
    /************************************************************/
    pub resource Vault {
        pub let name: String
        pub let id: UInt64
        pub var vault: @{String: NonFungibleToken.Collection}

        init(name: String, collection: @NonFungibleToken.Collection, collection_name: String) {
            DAAMAdminReceiver.vaultIDCounter = 0
            self.name = name
            self.id = DAAMAdminReceiver.vaultIDCounter
            DAAMAdminReceiver.vaultIDCounter = DAAMAdminReceiver.vaultIDCounter + 1 as UInt64
            self.vault <- {collection_name: <-collection}
        }

        destroy() { destroy self.vault }
    }
}
