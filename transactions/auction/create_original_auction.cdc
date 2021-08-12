// create_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(mid: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let metadataGen  : &DAAM.MetadataGenerator

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
      self.metadataGen  = auctioneer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
      //self.requestGen   = auctioneer.borrow<&DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
  }

  execute {
      let metadata <- self.metadataGen.generateMetadata(mid: mid)!

      self.auctionHouse.createOriginalAuction(metadata: <-metadata, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)!

      log("New Auction has been created.")
  }
}
