// get_current_auctions_status.cdc
// Return all auctions

import AuctionHouse from 0x045a1763c93006ca

pub fun main(status: Bool?): {Address : [UInt64] } {    
    return AuctionHouse.getCurrentAuctionsStatus(status) // Get auctioneers and AIDs {Address : [AID]}
}