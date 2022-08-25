// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V23         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V16 from 0x045a1763c93006ca

transaction(mid: UInt64, fee: UFix64)
{
    let mid: UInt64
    let fee: UFix64
    let admin: &DAAM_V23.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.fee = fee
        self.admin = admin.borrow<&DAAM_V23.Admin>(from: DAAM_V23.adminStoragePath)!
    }

    execute {
        AuctionHouse_V16.addFee(mid: self.mid, fee: self.fee, permission: self.admin)
    }
}
