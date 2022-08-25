// get_sale_history.cdc
// Return all (nil) or spcific sale history of TokenID


//import DAAM from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x045a1763c93006ca

pub fun main(id: UInt64?): {UInt64: AuctionHouse.SaleHistory}  {    
    return AuctionHouse.getSaleHistory(id: id)! // Get SaleHostory {TokenID : SaleHstory}
}