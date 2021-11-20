// get_all_auctions.cdc
// Return all auctions

import AuctionHouse  from 0x01837e15023c9249

pub fun main(): {Address : [UInt64]} {    
    return AuctionHouse.currentAuctions
}