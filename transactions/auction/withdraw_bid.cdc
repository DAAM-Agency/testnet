// make_bid.cdc

import FungibleToken from 0xee82856bf20e2aa6
import FUSD          from 0x192440c99cb17282
import AuctionHouse  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse.AuctionPublic}
    let fusdStoragePath : StoragePath
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder       
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: self.fusdStoragePath)!
        let amount <- self.auctionHouse.item(tokenID)!.withdrawBid(bidder: self.bidder)!
        vaultRef.deposit(from: <- amount)
    }
}
