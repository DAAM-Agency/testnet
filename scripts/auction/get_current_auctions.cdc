// get_current_auctions.cdc
// Return all auctions

<<<<<<< HEAD
import AuctionHouse_V4 from 0x1837e15023c9249

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_V4.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
=======
import AuctionHouse_V5 from 0x045a1763c93006ca

pub fun main(): {Address : [UInt64] } {    
    return AuctionHouse_V5.getCurrentAuctions() // Get auctioneers and AIDs {Address : [AID]}
>>>>>>> DAAM_V15
}