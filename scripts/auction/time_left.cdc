// time_left.cdc
// Return time left in auction

import AuctionHouse_V3 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V3.AuctionWallet{AuctionHouse_V3.AuctionWalletPublic}>
        (AuctionHouse_V3.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V3.Auction{AuctionHouse_V3.AuctionPublic}?   
    return mRef!.timeLeft()
}
