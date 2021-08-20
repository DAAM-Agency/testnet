// but_it_now.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
import FUSD          from 0x192440c99cb17282
import AuctionHouse  from 0x045a1763c93006ca
import DAAM_V3       from 0xa4ad5ea5c0bd2fba

transaction(auction: Address, tokenID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM_V3.CollectionPublic}
    
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
