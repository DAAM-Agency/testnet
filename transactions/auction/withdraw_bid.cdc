// withdraw_bid.cdc
// Used to withdraw bid made on item. Must not be lead bidder

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
import AuctionHouse_V14  from 0x045a1763c93006ca

transaction(auction: Address, aid: UInt64)
{
    let bidder          : AuthAccount
    let aid             : UInt64
    let auctionHouse    : &AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}
    let fusdStoragePath : StoragePath
    let vaultRef        : &FUSD.Vault{FungibleToken.Receiver}
    
    prepare(bidder: AuthAccount) {
        self.bidder          = bidder
        self.aid             = aid
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
            (AuctionHouse_V14.auctionPublicPath)
            .borrow()!
        self.vaultRef = bidder.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: self.fusdStoragePath)!
    }

    execute {
        let amount <- self.auctionHouse.item(self.aid)!.withdrawBid(bidder: self.bidder)!
        self.vaultRef.deposit(from: <- amount)
    }
}
