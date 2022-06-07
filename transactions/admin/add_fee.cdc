// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V12         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x1837e15023c9249

transaction(mid: UInt64, fee: UFix64)
{
    let mid: UInt64
    let fee: UFix64
    let admin: &DAAM_V12.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.fee = fee
        self.admin = admin.borrow<&DAAM_V12.Admin>(from: DAAM_V12.adminStoragePath)!
    }

    execute {
        AuctionHouse.addFee(mid: self.mid, fee: self.fee, permission: self.admin)
    }
}
