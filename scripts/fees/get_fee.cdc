// get_fee.cdc
// Gets the fee for a Metadata ID

<<<<<<< HEAD
import AuctionHouse_V16 from 0x01837e15023c9249
=======
import AuctionHouse_V16 from 0x01837e15023c9249
>>>>>>> tomerge

pub fun main(mid: UInt64): UFix64? {
    return AuctionHouse_V16.getFee(mid: mid) // 1.0 represents 100%
}
// nil = MID does not exist
