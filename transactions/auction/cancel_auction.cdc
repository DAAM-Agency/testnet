// cancel_auction.cdc
// Used to cancel an auction. There must have been be no bids made in order to cancel an auction.

<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249
import DAAM_V14          from 0xa4ad5ea5c0bd2fba
=======
import AuctionHouse_V5  from 0x045a1763c93006ca
import DAAM_V15          from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(aid: UInt64)
{
    let aid          : UInt64
    let auctioneer   : AuthAccount
<<<<<<< HEAD
    let auctionHouse : &AuctionHouse_V4.AuctionWallet
=======
    let auctionHouse : &AuctionHouse_V5.AuctionWallet
>>>>>>> DAAM_V15
    
    prepare(auctioneer: AuthAccount) {
        self.aid          = aid
        self.auctioneer   = auctioneer
<<<<<<< HEAD
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V4.AuctionWallet>(from: AuctionHouse_V4.auctionStoragePath)!
=======
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V5.AuctionWallet>(from: AuctionHouse_V5.auctionStoragePath)!
>>>>>>> DAAM_V15
    }

    execute {
        self.auctionHouse.setting(self.aid)!.cancelAuction()!
    }
}
