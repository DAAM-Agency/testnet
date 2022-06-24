// get_fee.cdc
// Gets the fee for a Metadata ID

<<<<<<< HEAD
import AuctionHouse_V4 from 0x1837e15023c9249

pub fun main(mid: UInt64): UFix64? {
    return AuctionHouse_V4.getFee(mid: mid) // 1.0 represents 100%
=======
import AuctionHouse_V5 from 0x045a1763c93006ca

pub fun main(mid: UInt64): UFix64? {
    return AuctionHouse_V5.getFee(mid: mid) // 1.0 represents 100%
>>>>>>> DAAM_V15
}
// nil = MID does not exist
