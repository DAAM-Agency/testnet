// get_current_auctions.cdc
// Return all auctions

import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_Mainnet.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
}