// deposit_bid.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
import AuctionHouse  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &AuctionHouse.AuctionWallet
    let flowStoragePath : StoragePath
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.flowStoragePath = /storage/flowTokenVault
        self.auctionHouse = getAccount(auction).getCapability<&AuctionHouse.AuctionWallet>(AuctionHouse.auctionPublicPath).borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: self.flowStoragePath)!
        let amount <- vaultRef.withdraw(amount: bid)!
        self.auctionHouse.item(tokenID)!.depositToBid(bidder: self.bidder, amount: <-amount)!
    }
}
