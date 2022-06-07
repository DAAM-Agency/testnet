// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

import AuctionHouse  from 0x1837e15023c9249
import DAAM_V12          from 0xa4ad5ea5c0bd2fba

transaction(aid: UInt64)
{
    let aid          : UInt64
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.aid          = aid
        self.auctioneer   = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.setting(self.aid)!.cancelAuction()!
    }
}
