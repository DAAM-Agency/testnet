// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V21         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V14 from 0x045a1763c93006ca

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM_V21.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V21.Admin>(from: DAAM_V21.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse_V14.removeFee(mid: self.mid, permission: self.admin)
    }
}
