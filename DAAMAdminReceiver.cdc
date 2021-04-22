// DAAM, // Ami Rajpal
// Based on TopShots
// https://github.com/dapperlabs/nba-smart-contracts/blob/master/contracts/TopShotAdminReceiver.cdc

/*
  AdminReceiver.cdc
  This contract defines a function that takes a DAAM Admin object and stores it in the storage of the contract account
  so it can be used.
 */

import DAAM from 0xf8d6e0586b0a20c7

pub contract DAAMAdminReceiver {
    pub fun storeAdmin(newAdmin: @DAAM.Admin) { self.account.save(<-newAdmin, to: /storage/TopShotAdmin) }
    
    init() {
            let collection <- DAAM.createEmptyCollection()  // Put a new Collection in storage            
            self.account.save(<-collection, to: /storage/DAAM)
            self.account.link<&{DAAM.NFT}>(/public/DAAM, target: /storage/DAAM)
        }
    }
}
