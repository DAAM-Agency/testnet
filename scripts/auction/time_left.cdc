// time_left.cdc

import AuctionHouse_V2  from 0x045a1763c93006ca

pub fun main(auction: Address, tokenID: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(tokenID)!.timeLeft()
}
