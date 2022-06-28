// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V8 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64? {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>
        (AuctionHouse_V8.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?  
    return mRef!.getMinBidAmount(bidder: bidder)
}