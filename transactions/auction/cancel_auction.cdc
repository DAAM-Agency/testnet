// cancel_auction.cdc

import AuctionHouse_V1 from 0x045a1763c93006ca
import DAAM_V3      from 0xa4ad5ea5c0bd2fba

transaction(tokenID: UInt64)
{
    let auctioneer   : AuthAccount
    let auctionHouse : &AuctionHouse_V1.AuctionWallet
    let collection   : &{DAAM_V3.CollectionPublic}
    
    prepare(auctioneer: AuthAccount) {
        self.auctioneer = auctioneer
        self.auctionHouse = auctioneer.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath)!
        self.collection = auctioneer.borrow<&{DAAM_V3.CollectionPublic}>(from: DAAM_V3.collectionStoragePath)!

    }

    execute {
        let nft <- self.auctionHouse.item(tokenID)!.cancelAuction(auctioneer: self.auctioneer)!
        self.collection.deposit(token: <- nft)
    }
}
