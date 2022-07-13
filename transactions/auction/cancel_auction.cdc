// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

import AuctionHouse_V11  from 0x01837e15023c9249
import DAAM_V18          from 0xa4ad5ea5c0bd2fba

transaction(aid: UInt64)
{
    let aid          : UInt64
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse_V11.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.aid          = aid
        self.auctioneer   = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V11.AuctionWallet>(from: AuctionHouse_V11.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.setting(self.aid)!.cancelAuction()!
    }
}
