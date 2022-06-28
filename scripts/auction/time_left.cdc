// time_left.cdc
// Return time left in auction

import AuctionHouse_V7 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V7.AuctionWallet{AuctionHouse_V7.AuctionWalletPublic}>
        (AuctionHouse_V7.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V7.Auction{AuctionHouse_V7.AuctionPublic}?   
    return mRef!.timeLeft()
}
