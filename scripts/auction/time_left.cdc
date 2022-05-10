// time_left.cdc
// Return time left in auction

import AuctionHouse from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionWalletPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(aid).timeLeft()
}
