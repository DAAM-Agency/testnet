// get_current_auctions.cdc
// Return all auctions

import AuctionHouse_V11 from 0x01837e15023c9249

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_V11.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
}