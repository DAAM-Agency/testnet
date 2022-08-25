// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V15 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64? {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V15.AuctionWallet{AuctionHouse_V15.AuctionWalletPublic}>
        (AuctionHouse_V15.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V15.Auction{AuctionHouse_V15.AuctionPublic}?  
    return mRef!.getMinBidAmount(bidder: bidder)
}