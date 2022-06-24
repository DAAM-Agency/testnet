// withdraw_bid.cdc
// Used to withdraw bid made on item. Must not be lead bidder

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249
=======
import AuctionHouse_V5  from 0x045a1763c93006ca
>>>>>>> DAAM_V15

transaction(auction: Address, aid: UInt64)
{
    let bidder          : AuthAccount
    let aid             : UInt64
<<<<<<< HEAD
    let auctionHouse    : &AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}
=======
    let auctionHouse    : &AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}
>>>>>>> DAAM_V15
    let fusdStoragePath : StoragePath
    let vaultRef        : &FUSD.Vault{FungibleToken.Receiver}
    
    prepare(bidder: AuthAccount) {
        self.bidder          = bidder
        self.aid             = aid
        self.fusdStoragePath = /storage/fusdVault
        self.auctionHouse = getAccount(auction)
<<<<<<< HEAD
            .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
            (AuctionHouse_V4.auctionPublicPath)
=======
            .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
            (AuctionHouse_V5.auctionPublicPath)
>>>>>>> DAAM_V15
            .borrow()!
        self.vaultRef = bidder.borrow<&FUSD.Vault{FungibleToken.Receiver}>(from: self.fusdStoragePath)!
    }

    execute {
        let amount <- self.auctionHouse.item(self.aid)!.withdrawBid(bidder: self.bidder)!
        self.vaultRef.deposit(from: <- amount)
    }
}
