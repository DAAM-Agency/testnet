// get_all_auctions.cdc
// Return all auctions

import AuctionHouse  from 0x045a1763c93006ca

pub fun main(): {Address : [UInt64]} {    
    return AuctionHouse.currentAuctions
}