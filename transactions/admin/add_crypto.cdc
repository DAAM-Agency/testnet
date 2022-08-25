// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
import DAAM_V22          from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V15  from 0x045a1763c93006ca


transaction()
{
    //let crypto: &FungibleToken.Vault
    let path  : PublicPath
    let admin : &DAAM_V22.Admin

    prepare(admin: AuthAccount) {
       
        //self.crypto = crypto
        self.path   = /public/fusdReceiver
        self.admin  = admin.borrow<&DAAM_V22.Admin>(from: DAAM_V22.adminStoragePath)!
    }

    execute {
        let vault <-FUSD.createEmptyVault()
        AuctionHouse_V15_V14.addCrypto(crypto: &vault as &FungibleToken.Vault, path: self.path, permission: self.admin)
        destroy vault
    }
}
