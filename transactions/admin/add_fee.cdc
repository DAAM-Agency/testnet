// add_fee.cdc
// Settles all auctions that have ended. Including Items, returning funds, etc.

import DAAM_Mainnet         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet from 0x01837e15023c9249

transaction(mid: UInt64, fee: UFix64)
{
    let mid: UInt64
    let fee: UFix64
    let admin: &DAAM_Mainnet.Admin

    prepare(admin: AuthAccount) {
        self.mid = mid
        self.fee = fee
        self.admin = admin.borrow<&DAAM_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    execute {
        AuctionHouse_Mainnet.addFee(mid: self.mid, fee: self.fee, permission: self.admin)
    }
}
