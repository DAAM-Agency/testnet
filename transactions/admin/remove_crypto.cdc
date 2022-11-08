// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0x0bb80b2a4cb38cdf
import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet  from 0x045a1763c93006ca


transaction(crypto: String)
{
    let crypto : String
    let admin  : &DAAM_Mainnet.Admin

    prepare(admin: AuthAccount) {
       
        self.crypto = crypto
        self.admin  = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    execute {
        AuctionHouse_Mainnet.removeCrypto(crypto: self.crypto, permission: self.admin)
    }
}
