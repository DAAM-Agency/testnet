// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import DAAM          from 0xfd43f9148d4b725d
import AuctionHouse  from 0x045a1763c93006ca


transaction(crypto: String)
{
    let crypto : String
    let admin  : &DAAM.Admin

    prepare(admin: AuthAccount) {
       
        self.crypto = crypto
        self.admin  = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    execute {
        AuctionHouse.removeCrypto(crypto: self.crypto, permission: self.admin)
    }
}
