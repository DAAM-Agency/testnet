// buy_it_now_status.cdc
// Return is there is a Buy It Now option. If there is not or it expired, this will return false.

import AuctionHouse  from 0x01837e15023c9249

pub fun main(auction: Address, aid: UInt64): Bool {    
    let auctionHouse = getAccount(auction)
        .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
        .borrow()!
    return auctionHouse.item(aid)!.buyItNowStatus()
}
