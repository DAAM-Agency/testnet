// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V2 from 0x1837e15023c9249

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64 {
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(aid).getBuyNowAmount(bidder: bidder)
}