// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
<<<<<<< HEAD
import DAAM_V22          from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V22          from 0xa4ad5ea5c0bd2fba
>>>>>>> 586a0096 (updated FUSD Address)
import AuctionHouse_V15  from 0x045a1763c93006ca


transaction()
{
    //let crypto: &FungibleToken.Vault
    let path  : PublicPath
    let admin : &DAAM_V22.Admin

    prepare(admin: AuthAccount) {
       
        //self.crypto = crypto
        self.path   = /public/fusdReceiver
<<<<<<< HEAD
        self.admin  = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
=======
        self.admin  = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
    }

    execute {
        let vault <-FUSD.createEmptyVault()
        AuctionHouse_V15_V14.addCrypto(crypto: &vault as &FungibleToken.Vault, path: self.path, permission: self.admin)
        destroy vault
    }
}
