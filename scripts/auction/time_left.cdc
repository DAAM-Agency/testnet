// time_left.cdc
// Return time left in auction

import AuctionHouse_V2.V2from 0x045a1763c93006ca

pub fun main(auction: Address, aid: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(aid).timeLeft()
}
