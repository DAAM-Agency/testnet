// get_buy_now_amount.cdc
// Gets the amount required for a Buy It Now

import AuctionHouse_Mainnet from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64, bidder: Address): UFix64 {
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
        (AuctionHouse_Mainnet.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_Mainnet.Auction{AuctionHouse_Mainnet.AuctionPublic}?  
    return mRef!.getBuyNowAmount(bidder: bidder)
}