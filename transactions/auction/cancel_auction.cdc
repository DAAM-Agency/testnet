// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

import AuctionHouse  from 0x01837e15023c9249
import DAAM_V7          from 0xa4ad5ea5c0bd2fba

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
