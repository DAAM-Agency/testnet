// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

<<<<<<< HEAD
import DAAM_V14         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V4 from 0x1837e15023c9249
=======
import DAAM_V15         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V5 from 0x045a1763c93006ca
>>>>>>> DAAM_V15

transaction(mid: UInt64, fee: UFix64)
{
    let mid: UInt64
    let fee: UFix64
<<<<<<< HEAD
    let admin: &DAAM_V14.Admin
=======
    let admin: &DAAM_V15.Admin
>>>>>>> DAAM_V15

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.fee = fee
<<<<<<< HEAD
        self.admin = admin.borrow<&DAAM_V14.Admin>(from: DAAM_V14.adminStoragePath)!
    }

    execute {
        AuctionHouse_V4.addFee(mid: self.mid, fee: self.fee, permission: self.admin)
=======
        self.admin = admin.borrow<&DAAM_V15.Admin>(from: DAAM_V15.adminStoragePath)!
    }

    execute {
        AuctionHouse_V5.addFee(mid: self.mid, fee: self.fee, permission: self.admin)
>>>>>>> DAAM_V15
    }
}
