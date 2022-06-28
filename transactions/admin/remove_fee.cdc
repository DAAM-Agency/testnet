// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V17         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V7 from 0x01837e15023c9249

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM_V17.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V17.Admin>(from: DAAM_V17.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse_V7.removeFee(mid: self.mid, permission: self.admin)
    }
}
