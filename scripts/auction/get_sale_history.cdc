// get_sale_history.cdc
// Return all (nil) or spcific sale history of TokenID


//import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet from 0x01837e15023c9249

pub fun main(id: UInt64?): {UInt64: AuctionHouse_Mainnet.SaleHistory}?  {    
    return AuctionHouse_Mainnet.getSaleHistory(id: id) // Get SaleHostory {TokenID : SaleHstory}
}