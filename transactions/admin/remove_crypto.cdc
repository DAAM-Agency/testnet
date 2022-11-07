// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0x192440c99cb17282
import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet  from 0x045a1763c93006ca


transaction(crypto: String)
{
    let crypto : String
    let admin  : &DAAMDAAM_Mainnet_Mainnet.Admin

    prepare(admin: AuthAccount) {
       
        self.crypto = crypto
        self.admin  = admin.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    execute {
        AuctionHouse_Mainnet.removeCrypto(crypto: self.crypto, permission: self.admin)
    }
}
