// time_left.cdc
// Return time left in auction

import AuctionHouse_V8 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V8.AuctionWallet{AuctionHouse_V8.AuctionWalletPublic}>
        (AuctionHouse_V8.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V8.Auction{AuctionHouse_V8.AuctionPublic}?   
    return mRef!.timeLeft()
}
