// but_it_now.cdc
// Used for direct purchases

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
import AuctionHouse  from 0x01837e15023c9249
import DAAM_V5          from 0xa4ad5ea5c0bd2fba

transaction(auction: Address, auctionID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM_V5.CollectionPublic}
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    let auctionID       : UInt64
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.fusdStoragePath = /storage/fusdVault

        self.vaultRef   = self.bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
        self.collection = self.bidder.borrow<&{DAAM_V5.CollectionPublic}>(from: DAAM_V5.collectionStoragePath)!
        
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!

<<<<<<< HEAD
        self.collection = getAccount(bidder.address)
            .getCapability<&{DAAM_V5.CollectionPublic}>(DAAM_V5.collectionPublicPath)
            .borrow()!
=======
        self.auctionID = auctionID
>>>>>>> merge_dev
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: bid)!
        self.auctionHouse.item(self.auctionID)!.buyItNow(bidder: self.bidder, amount: <-amount)!
    }
}
