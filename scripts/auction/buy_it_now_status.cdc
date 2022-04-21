// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse_V2.V2from 0x045a1763c93006ca

pub fun main(auction: Address, auctionID: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
        .borrow()!
        
    return auctionHouse.item(auctionID).buyItNowStatus()
}
