// but_it_now.cdc
// Used for direct purchases

import FungibleToken from 0x9a0766d93b6608b7
import FUSD          from 0xe223d8a629e49c68
import AuctionHouse_V14  from 0x045a1763c93006ca
import DAAM_V21          from 0xa4ad5ea5c0bd2fba

transaction(auction: Address, aid: UInt64, bid: UFix64)
{
    let bidder          : Address
    let auctionHouse    : &AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}
    let fusdStoragePath : StoragePath
    let collection      : &{DAAM_V21.CollectionPublic}
    let vaultRef        : &FUSD.Vault{FungibleToken.Provider}
    let aid             : UInt64
    let bid             : UFix64
    
    prepare(bidder: AuthAccount) {
        self.bidder = bidder.address
        self.fusdStoragePath = /storage/fusdVault
        self.vaultRef   = bidder.borrow<&FUSD.Vault{FungibleToken.Provider}>(from: self.fusdStoragePath)!
        self.collection = bidder.borrow<&{DAAM_V21.CollectionPublic}>(from: DAAM_V21.collectionStoragePath)!
        self.auctionHouse = getAccount(auction)
            .getCapability<&AuctionHouse_V14.AuctionWallet{AuctionHouse_V14.AuctionWalletPublic}>
            (AuctionHouse_V14.auctionPublicPath)
            .borrow()!

        self.aid = aid
        self.bid = bid
    }

    execute {
        let amount <- self.vaultRef.withdraw(amount: self.bid)!
        self.auctionHouse.item(self.aid)!.buyItNow(bidder: self.bidder, amount: <-amount)!
    }
}
