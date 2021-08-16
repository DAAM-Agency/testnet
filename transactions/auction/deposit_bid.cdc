// deposit_bid.cdc

import FungibleToken from 0xee82856bf20e2aa6
import FlowToken     from 0x0ae53cb6e3f42a79
import AuctionHouse  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64, bid: UFix64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let flowStoragePath : StoragePath
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder
        self.flowStoragePath = /storage/flowTokenVault
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: self.flowStoragePath)!
        let amount <- vaultRef.withdraw(amount: bid)!
        self.auctionHouse.item(tokenID)!.depositToBid(bidder: self.bidder, amount: <-amount)!
    }
}
