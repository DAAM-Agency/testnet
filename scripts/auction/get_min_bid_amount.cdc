// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V12 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64? {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V12.AuctionWallet{AuctionHouse_V12.AuctionWalletPublic}>
        (AuctionHouse_V12.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V12.Auction{AuctionHouse_V12.AuctionPublic}?  
    return mRef!.getMinBidAmount(bidder: bidder)
}