// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x045a1763c93006ca

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse.removeFee(mid: self.mid, permission: self.admin)
    }
}
