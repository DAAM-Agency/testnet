// get_fee.cdc
// Gets the fee for a Metadata ID

import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(mid: UInt64): UFix64? {
    return AuctionHouse_Mainnet.getFee(mid: mid) // 1.0 represents 100%
}
// nil = MID does not exist
