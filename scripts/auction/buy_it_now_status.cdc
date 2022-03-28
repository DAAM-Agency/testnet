// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse  from 0x045a1763c93006ca

pub fun main(auction: Address, tokenID: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
    return auctionHouse.item(tokenID).buyItNowStatus()
}
