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
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.fusdStoragePath = /storage/fusdVault
        
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!

        self.collection = getAccount(bidder.address)
            .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
            .borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
        let amount <- vaultRef.withdraw(amount: bid)!
        let nft <- self.auctionHouse.item(tokenID)!.buyItNow(bidder: self.bidder, amount: <-amount)!
        self.collection.deposit(token: <- nft)
    }
}
