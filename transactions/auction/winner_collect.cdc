// winner_collect.cdc

import AuctionHouse_V2  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse_V2.AuctionPublic}
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder       
        self.auctionHouse = getAccount(auction).getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath).borrow()!
    }

    execute {
        self.auctionHouse.item(tokenID)!.winnerCollect(bidder: self.bidder)!
    }
}
