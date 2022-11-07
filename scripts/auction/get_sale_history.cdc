// get_sale_history.cdc
// Return all (nil) or spcific sale history of TokenID


//import DAAM_Mainnet from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub fun main(id: UInt64?): {UInt64: AuctionHouse.SaleHistory}?  {    
    return AuctionHouse.getSaleHistory(id: id) // Get SaleHostory {TokenID : SaleHstory}
}