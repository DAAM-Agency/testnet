// get_fee.cdc
// Gets the fee for a Metadata ID

import AuctionHouse_V5 from 0x01837e15023c9249

pub fun main(mid: UInt64): UFix64? {
    return AuctionHouse_V5.getFee(mid: mid) // 1.0 represents 100%
}
// nil = MID does not exist
