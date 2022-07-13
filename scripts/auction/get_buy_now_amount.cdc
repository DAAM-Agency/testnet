// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_V10 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64 {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V10.AuctionWallet{AuctionHouse_V10.AuctionWalletPublic}>
        (AuctionHouse_V10.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V10.Auction{AuctionHouse_V10.AuctionPublic}?  
    return mRef!.getBuyNowAmount(bidder: bidder)
}