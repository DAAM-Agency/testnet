// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse from0x1837e15023c9249

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64 {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
        (AuctionHouse.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse.Auction{AuctionHouse.AuctionPublic}?  
    return mRef!.getBuyNowAmount(bidder: bidder)
}