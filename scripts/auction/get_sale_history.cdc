// get_sale_history.cdc
// Return all (nil) or spcific sale history


//import DAAM_V20 from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V12 from 0x045a1763c93006ca

pub fun main(id: UInt64?): {UInt64: AuctionHouse_V12.SaleHistory}  {    
    return AuctionHouse_V12.getSaleHistory(id: id) // Get SaleHostory {TokenID : SaleHstory}
}