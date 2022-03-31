// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): UFix64 { 
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(auctionID).getBuyNowAmount(bidder: auction)
}