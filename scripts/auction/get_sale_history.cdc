// get_sale_history.cdc
// Return all (nil) or spcific sale auctions


import AuctionHouse_V8 from 0x01837e15023c9249

pub fun main(id: UInt64?): {UInt64 : [AuctionHouse_V8.SaleHistory] } {    
    return AuctionHouse_V8.getSaleHistory(id: id) // Get SaleHostory {TokenID : SaleHstory}
}