// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_Mainnet         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction(mid: UInt64)
{
    let mid: UInt64
    let admin: &DAAM_Mainnet.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse_Mainnet.removeFee(mid: self.mid, permission: self.admin)
    }
}
