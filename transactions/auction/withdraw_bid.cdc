// withdraw_bid.cdc
// Used to withdraw bid made on item. Must not be lead bidder

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import AuctionHouse  from 0x045a1763c93006ca

transaction(auction: Address, aid: UInt64)
{
    let aid             : UInt64
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    let vaultRef        : &FUSD.Vault{FungibleToken.Receiver}
    
    prepare(bidder: AuthAccount) {
        self.aid             = aid
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse    = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!
        self.vaultRef = bidder.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: self.fusdStoragePath)!
    }

    execute {
        let amount <- self.auctionHouse.item(self.aid)!.withdrawBid()!
        self.vaultRef.deposit(from: <- amount)
    }
}
