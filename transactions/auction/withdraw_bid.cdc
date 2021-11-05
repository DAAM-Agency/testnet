// make_bid.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
import FUSD          from 0xe223d8a629e49c68
import AuctionHouse_V2  from 0x045a1763c93006ca

transaction(auction: Address, tokenID: UInt64)
{
    let bidder          : AuthAccount
    let auctionHouse    : &{AuctionHouse_V2.AuctionPublic}
    let fusdStoragePath : StoragePath
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder       
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse = getAccount(auction)
            .getCapability<&{AuctionHouse_V2.AuctionPublic}>(AuctionHouse_V2.auctionPublicPath)
            .borrow()!
    }

    execute {
        let vaultRef = self.bidder.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: self.fusdStoragePath)!
        let amount <- self.auctionHouse.item(tokenID)!.withdrawBid(bidder: self.bidder)!
        vaultRef.deposit(from: <- amount)
    }
}
