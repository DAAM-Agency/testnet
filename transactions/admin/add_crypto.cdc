// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import DAAM_Mainnet          from 0xfd43f9148d4b725d
import AuctionHouse_Mainnet  from 0x045a1763c93006ca


transaction()
{
    //let crypto: &FungibleToken.Vault
    let path  : PublicPath
    let admin : &DAAMDAAM_Mainnet_Mainnet.Admin

    prepare(admin: AuthAccount) {
       
        //self.crypto = crypto
        self.path   = /public/fusdReceiver
        self.admin  = admin.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    execute {
        let vault <-FUSD.createEmptyVault()
        AuctionHouse_Mainnet.addCrypto(crypto: &vault as &FungibleToken.Vault, path: self.path, permission: self.admin)
        destroy vault
    }
}
