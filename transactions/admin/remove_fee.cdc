// remove_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

<<<<<<< HEAD
import DAAM_V10         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249
=======
import DAAM_V14         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V4 from 0x045a1763c93006ca
>>>>>>> DAAM_V14

transaction(mid: UInt64)
{
    let mid: UInt64
<<<<<<< HEAD
    let admin: &DAAM_V10.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V10.Admin>(from: DAAM_V10.adminStoragePath)!
    }

    execute {
        AuctionHouse_V2.removeFee(mid: self.mid, permission: self.admin)
=======
    let admin: &DAAM_V14.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.admin = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath) ?? panic("You are not an Admin.")
    }

    execute {
        AuctionHouse_V4.removeFee(mid: self.mid, permission: self.admin)
>>>>>>> DAAM_V14
    }
}
