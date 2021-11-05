// create_auction.cdc

import AuctionHouse_V1     from 0x045a1763c93006ca
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V4             from 0xa4ad5ea5c0bd2fba

transaction(mid: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse_V1.AuctionWallet
  let metadataCap  : Capability<&DAAM_V4.MetadataGenerator>

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath)!
      self.metadataCap  = auctioneer.getCapability<&DAAM_V4.MetadataGenerator>(DAAM_V4.metadataPublicPath)!
  }

  execute {
      self.auctionHouse.createOriginalAuction(metadataGenerator: self.metadataCap, mid: mid, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)!

      log("New Auction has been created.")
  }
}
