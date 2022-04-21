// winner_collect.cdc
// Used to claim an item. Must meet reserve price.

import AuctionHouse_V2.V2 from 0x045a1763c93006ca
transaction(auction: Address, aid: UInt64)
{ 
    let aid          : UInt64
    let auctionHouse : &{AuctionHouse_V2.AuctionPublic}
    
    prepare(bidder: AuthAccount) {
        self.aid          = aid
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
            .borrow()!
    }

    execute {
        self.auctionHouse.item(self.aid)!.winnerCollect()
    }
}
