// get_history.cdc
// Return all (nil) or spcific history


//import DAAM_V23 from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V15 from 0x045a1763c93006ca

pub fun main(mid: UInt64?): {UInt64 : {UInt64: AuctionHouse_V15.SaleHistory}} { // MID : {TokenID:SaleHistory} }
    return AuctionHouse_V15.getHistory(mid: mid)! // Get SaleHostory {TokenID : SaleHstory}
}