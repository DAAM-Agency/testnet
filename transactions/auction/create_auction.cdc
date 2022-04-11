// create_auction.cdc
// Used to create an auction for an NFT

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V8.V8.V8_V8..             from 0xa4ad5ea5c0bd2fba

transaction(tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
{

  let auctionHouse : &AuctionHouse.AuctionWallet
  let nftCollection: &DAAM_V8.V8..Collection

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
    self.nftCollection = auctioneer.borrow<&DAAM_V8.V8..Collection>(from: DAAM_V8.V8..collectionStoragePath)!

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
      let nft <- self.nftCollection.withdraw(withdrawID: self.tokenID) as! @DAAM_V8.V8..NFT

      self.auctionHouse.createAuction(nft: <-nft, start: self.start, length: self.length, isExtended: self.isExtended,
        extendedTime: self.extendedTime, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow)

      log("New Auction created.")
  }
}
