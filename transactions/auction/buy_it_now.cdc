// but_it_now.cdc

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import AuctionHouse  from 0x045a1763c93006ca
import DAAM          from 0xfd43f9148d4b725d

transaction(auction: Address, tokenID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM.CollectionPublic}
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.fusdStoragePath = /storage/fusdVault

        self.vaultRef   = self.bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
        self.collection = self.bidder.borrow<&{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath)!
        
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!
    }

    pre {
        getAccount(auction).borrow<&{AuctionHouse.AuctionPublic}>() != nil : "
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: bid)!
        self.auctionHouse.item(tokenID)!.buyItNow(bidder: self.bidder, amount: <-amount)!
    }
}
