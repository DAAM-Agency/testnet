// get_current_auctions_status.cdc
// Return all auctions

import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(status: Bool?): {Address : [UInt64] } {    
    return AuctionHouse_Mainnet.getCurrentAuctionsStatus(status) // Get auctioneers and AIDs {Address : [AID]}
}