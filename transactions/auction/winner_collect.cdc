
// winner_collect.cdc

import AuctionHouse_V1  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse_V1.AuctionPublic}
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder       
        self.auctionHouse = getAccount(auction).getCapability<&{AuctionHouse_V1.AuctionPublic}>(AuctionHouse_V1.auctionPublicPath).borrow()!
    }

    execute {
        self.auctionHouse.item(tokenID)!.winnerCollect(bidder: self.bidder)!
    }
}
