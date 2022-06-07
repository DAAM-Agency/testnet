// get_current_auctions.cdc
// Return all auctions

import AuctionHouse from0x1837e15023c9249

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
}