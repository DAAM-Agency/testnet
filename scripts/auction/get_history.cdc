// get_history.cdc
// Return all (nil) or spcific history


//import DAAM from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub fun main(mid: UInt64?): {UInt64 : {UInt64: AuctionHouse.SaleHistory}} { // MID : {TokenID:SaleHistory} }
    return AuctionHouse.getHistory(mid: mid)! // Get SaleHostory {TokenID : SaleHstory}
}