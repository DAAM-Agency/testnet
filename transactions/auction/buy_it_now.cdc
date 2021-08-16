// but_it_now.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
import AuctionHouse  from 0x045a1763c93006ca
import DAAM_V3          from 0xa4ad5ea5c0bd2fba

transaction(auction: Address, tokenID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &AuctionHouse.AuctionWallet
    let flowStoragePath : StoragePath
    let collection      : &{DAAM_V3.CollectionPublic}
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.flowStoragePath = /storage/flowTokenVault
        self.auctionHouse = getAccount(auction).getCapability<&AuctionHouse.AuctionWallet>(AuctionHouse.auctionPublicPath).borrow()!
        self.collection = getAccount(bidder.address).getCapability<&{DAAM_V3.CollectionPublic}>(DAAM_V3.collectionPublicPath).borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: self.flowStoragePath)!
        let amount <- vaultRef.withdraw(amount: bid)!
        let nft <- self.auctionHouse.item(tokenID)!.buyItNow(bidder: self.bidder, amount: <-amount)!
        self.collection.deposit(token: <- nft)
    }
}
