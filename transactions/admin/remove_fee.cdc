// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_V11         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x045a1763c93006ca

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM_V11.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V11.Admin>(from: DAAM_V11.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse.removeFee(mid: self.mid, permission: self.admin)
    }
}
