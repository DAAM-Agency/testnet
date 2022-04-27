// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V10         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM_V10.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
    }

    execute {
        AuctionHouse_V2.removeFee(mid: self.mid, permission: self.admin)
    }
}
