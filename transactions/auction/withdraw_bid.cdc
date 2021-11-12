// withdraw_bid.cdc
// Used to withdraw bid made on item. Must not be lead bidder

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
import AuctionHouse  from 0x01837e15023c9249

transaction(auction: Address, auctionID: UInt64)
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
        let amount <- self.auctionHouse.item(auctionID)!.withdrawBid(bidder: self.bidder)!
        vaultRef.deposit(from: <- amount)
    }
}
