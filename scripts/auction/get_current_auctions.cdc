// get_current_auctions.cdc
// Return all auctions

import AuctionHouse_V15 from 0x045a1763c93006ca

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_V15.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
}