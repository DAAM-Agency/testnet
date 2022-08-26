// get_history.cdc
// Return all (nil) or spcific history


//import DAAM_V23 from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V16 from 0x01837e15023c9249

pub fun main(mid: UInt64?): {UInt64 : {UInt64: AuctionHouse_V16.SaleHistory}} { // MID : {TokenID:SaleHistory} }
    return AuctionHouse_V16.getHistory(mid: mid)! // Get SaleHostory {TokenID : SaleHstory}
}