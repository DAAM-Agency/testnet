// create_auction.cdc
// Used to create an auction for a first-time sale.

import AuctionHouse     from 0x01837e15023c9249
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V6          from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let metadataCap  : Capability<&DAAM_V6.MetadataGenerator{DAAM_V6.MetadataGeneratorMint}>

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
      self.metadataCap  = auctioneer.getCapability<&DAAM_V6.MetadataGenerator{DAAM_V6.MetadataGeneratorMint}>(DAAM_V6.metadataPublicPath)!
  }

  execute {
      self.auctionHouse.createOriginalAuction(metadataGenerator: self.metadataCap, mid: mid, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)!

      log("New Auction has been created.")
  }
}
