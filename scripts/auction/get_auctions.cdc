// get_auctions.cdc

import AuctionHouse_V1  from 0x045a1763c93006ca


pub fun main(auction: Address): [UInt64] {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V1.AuctionPublic}>(AuctionHouse_V1.auctionPublicPath)
        .borrow()!

    return auctionHouse.getAuctions()
}