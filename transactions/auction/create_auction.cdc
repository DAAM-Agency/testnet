// create_auction.cdc
// Used to create an auction for an NFT

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
{

  let auctionHouse : &AuctionHouse.AuctionWallet
  let nftCollection: &DAAM.Collection

  let tokenID     : UInt64
  let start       : UFix64
  let length      : UFix64
  let isExtended  : Bool
  let extendedTime: UFix64
  let incrementByPrice: Bool
  let incrementAmount : UFix64
  let startingBid : UFix64?
  let reserve     : UFix64
  let buyNow      : UFix64

  prepare(auctioneer: AuthAccount) {
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)!

    self.tokenID          = tokenID
    self.start            = start
    self.length           = length
    self.isExtended       = isExtended
    self.extendedTime     = extendedTime
    self.incrementByPrice = incrementByPrice
    self.incrementAmount  = incrementAmount
    self.startingBid      = startingBid
    self.reserve          = reserve
    self.buyNow           = buyNow
  }

  execute {
      let nft <- self.nftCollection.withdraw(withdrawID: self.tokenID) as! @DAAM.NFT

      self.auctionHouse.createAuction(nft: <-nft, start: self.start, length: self.length, isExtended: self.isExtended,
        extendedTime: self.extendedTime, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow)

      log("New Auction created.")
  }
}
