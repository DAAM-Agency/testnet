// cancel_auction.cdc

import AuctionHouse  from 0x045a1763c93006ca
import DAAM_V2.V2          from 0xa4ad5ea5c0bd2fba

transaction(tokenID: UInt64)
{
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse.AuctionWallet
    let collection   : &{DAAM_V2.CollectionPublic}
    
    prepare(auctioneer: AuthAccount) {
        self.auctioneer = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
        self.collection = auctioneer.borrow<&{DAAM_V2.CollectionPublic}>(from: DAAM_V2.collectionStoragePath)!
    }

    execute {
        let nft <- self.auctionHouse.item(tokenID)!.cancelAuction(auctioneer: self.auctioneer)!
        self.collection.deposit(token: <- nft)
    }
}
