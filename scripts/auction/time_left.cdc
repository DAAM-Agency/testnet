// time_left.cdc
// Return time left in auction

import AuctionHouse_V16 from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V16.AuctionWallet{AuctionHouse_V16.AuctionWalletPublic}>
        (AuctionHouse_V16.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V16.Auction{AuctionHouse_V16.AuctionPublic}?   
    return mRef!.timeLeft()
}
