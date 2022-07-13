// time_left.cdc
// Return time left in auction

import AuctionHouse_V10 from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&AuctionHouse_V10.AuctionWallet{AuctionHouse_V10.AuctionWalletPublic}>
        (AuctionHouse_V10.auctionPublicPath)
        .borrow()!

    let mRef = auctionHouse.item(aid) as &AuctionHouse_V10.Auction{AuctionHouse_V10.AuctionPublic}?   
    return mRef!.timeLeft()
}
