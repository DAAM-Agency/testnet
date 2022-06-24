// but_it_now.cdc
// Used for direct purchases

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
<<<<<<< HEAD
import AuctionHouse_V4  from 0x1837e15023c9249
import DAAM_V14          from 0xa4ad5ea5c0bd2fba
=======
import AuctionHouse_V5  from 0x045a1763c93006ca
import DAAM_V15          from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction(auction: Address, aid: UInt64, bid: UFix64)
{
    let bidder          : Address
<<<<<<< HEAD
    let auctionHouse    : &AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM_V14.CollectionPublic}
=======
    let auctionHouse    : &AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM_V15.CollectionPublic}
>>>>>>> DAAM_V15
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    let aid             : UInt64
    let bid             : UFix64
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder.address
        self.fusdStoragePath = /storage/fusdVault
        self.vaultRef   = bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
<<<<<<< HEAD
        self.collection = bidder.borrow<&{DAAM_V14.CollectionPublic}>(from: DAAM_V14.collectionStoragePath)!
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V4.AuctionWallet{AuctionHouse_V4.AuctionWalletPublic}>
            (AuctionHouse_V4.auctionPublicPath)
=======
        self.collection = bidder.borrow<&{DAAM_V15.CollectionPublic}>(from: DAAM_V15.collectionStoragePath)!
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V5.AuctionWallet{AuctionHouse_V5.AuctionWalletPublic}>
            (AuctionHouse_V5.auctionPublicPath)
>>>>>>> DAAM_V15
            .borrow()!

        self.aid = aid
        self.bid = bid
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: self.bid)!
        self.auctionHouse.item(self.aid)!.buyItNow(bidder: self.bidder, amount: <-amount)!
    }
}
