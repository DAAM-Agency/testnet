// get_history.cdc
// Return all (nil) or spcific history


//import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(mid: UInt64?): {UInt64 : {UInt64: AuctionHouse_Mainnet.SaleHistory}}? { // {Creator { MID : {TokenID:SaleHistory} } }
    return AuctionHouse_Mainnet.getHistory(mid: mid) // Get SaleHostory {TokenID : SaleHstory}
}