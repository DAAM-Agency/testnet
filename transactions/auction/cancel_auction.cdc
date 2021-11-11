// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

import AuctionHouse  from 0x045a1763c93006ca
import DAAM          from 0xfd43f9148d4b725d

transaction(auctionID: UInt64)
{
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.auctioneer = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.item(auctionID)!.cancelAuction(auctioneer: self.auctioneer)!
    }
}
