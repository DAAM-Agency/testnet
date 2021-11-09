// time_left.cdc

import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, tokenID: UInt64): UFix64? {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(tokenID)!.timeLeft()
}
