// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

import AuctionHouse_V12  from 0x045a1763c93006ca
import DAAM_V19          from 0xa4ad5ea5c0bd2fba

transaction(aid: UInt64)
{
    let aid          : UInt64
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse_V12.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.aid          = aid
        self.auctioneer   = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V12.AuctionWallet>(from: AuctionHouse_V12.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.setting(self.aid)!.cancelAuction()!
    }
}
