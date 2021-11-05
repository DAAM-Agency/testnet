// cancel_auction.cdc

import AuctionHouse_V2 from 0x045a1763c93006ca
import DAAM_V4      from 0xa4ad5ea5c0bd2fba

transaction(tokenID: UInt64)
{
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse_V2.AuctionWallet
    
    prepare(auctioneer: AuthAccount) {
        self.auctioneer = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath)!
    }

    execute {
        self.auctionHouse.item(tokenID)!.cancelAuction(auctioneer: self.auctioneer)!
    }
}
