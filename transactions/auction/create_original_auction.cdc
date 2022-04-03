// create_auction.cdc
// Used to create an auction for a first-time sale.

import AuctionHouse     from 0x045a1763c93006ca
// import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(mid: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let metadataCap  : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>

  let mid         : UInt64
  let start       : UFix64
  let length      : UFix64
  let isExtended  : Bool
  let extendedTime: UFix64
  let incrementByPrice: Bool
  let incrementAmount : UFix64
  let startingBid : UFix64?
  let reserve     : UFix64
  let buyNow      : UFix64
  let reprintSeries   : Bool  

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!      
      self.metadataCap  = auctioneer.getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>(DAAM.metadataPublicPath)!

      self.mid              = mid
      self.start            = start
      self.length           = length
      self.isExtended       = isExtended
      self.extendedTime     = extendedTime
      self.incrementByPrice = incrementByPrice
      self.incrementAmount  = incrementAmount
      self.startingBid      = startingBid
      self.reserve          = reserve
      self.buyNow           = buyNow
      self.reprintSeries    = reprintSeries
  }
  
  execute {
      self.auctionHouse.createOriginalAuction(metadataGenerator: self.metadataCap!, mid: self.mid, start: self.start, length: self.length,
        isExtended: self.isExtended, extendedTime: self.extendedTime, incrementByPrice: self.incrementByPrice,incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprintSeries
      )

      log("New Auction has been created.")
  }
}
