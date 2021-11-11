// but_it_now.cdc
// Used for direct purchases

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import AuctionHouse  from 0x045a1763c93006ca
import DAAM          from 0xfd43f9148d4b725d

transaction(auction: Address, auctionID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM.CollectionPublic}
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    let auctionID       : UInt64
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.fusdStoragePath = /storage/fusdVault

        self.vaultRef   = self.bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
        self.collection = self.bidder.borrow<&{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath)!
        
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!

        self.auctionID = auctionID
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: bid)!
        self.auctionHouse.item(self.auctionID)!.buyItNow(bidder: self.bidder, amount: <-amount)!
    }
}
