// get_current_auctions.cdc
// Return all auctions

import AuctionHouse_V8 from 0x01837e15023c9249

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_V8.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
}