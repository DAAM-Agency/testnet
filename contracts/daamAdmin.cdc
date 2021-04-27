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

pub contract DAAMAdmin {
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
    pub resource Admin {
        /*pub fun createSet(name: String) {
            // Create the new Set
            var newSet <- create Set(name: name)

            // Store it in the sets mapping field
            TopShot.sets[newSet.setID] <-! newSet
        }
        pub fun createCollection(): @Collection { return <- create Collection ()  }// Create the new collection     

       // borrowCollection returns a reference to a set in the DAAM contract so that the admin can call methods on it
        pub fun borrowCollection(id: UInt64): &Collection {
            pre { DAAM.collection[setID] != nil: "Cannot borrow Set: The Set doesn't exist" }            
            // Get a reference to the Set and return it use `&` to indicate the reference to the object and type
            return &DAAM.sets[setID] as &Set
        }*/

        pub fun createNewAdmin(): @Admin { return <-create Admin() }   // createNewAdmin creates a new Admin resource
    }
    /************************************************************/
    pub resource Vault {
        pub let name: String
        pub let id: UInt64
        pub var vault: @{String: NonFungibleToken.Collection}

        init(name: String) {
            DAAMAdmin.vaultIDCounter = 0
            self.name = name
            self.id = DAAMAdmin.vaultIDCounter
            DAAMAdmin.vaultIDCounter = DAAMAdmin.vaultIDCounter + 1 as UInt64
            self.vault <- {}
        }

        destroy() { destroy self.vault } // TODO SHOULD IT BE MOVED INSTEAD, USING DEFAULT
    }
}
