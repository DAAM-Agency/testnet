// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V5 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64 {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
        (AuctionHouse_V5.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V5.Auction{AuctionHouse_V5.AuctionPublic}?  
    return mRef!.getBuyNowAmount(bidder: bidder)
}