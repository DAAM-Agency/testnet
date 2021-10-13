// winner_collect.cdc

import AuctionHouse  from 0x045a1763c93006ca
transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder       
        self.auctionHouse = getAccount(auction).getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath).borrow()!
    }

    execute {
        self.auctionHouse.item(tokenID)!.winnerCollect(bidder: self.bidder)!
    }
}
