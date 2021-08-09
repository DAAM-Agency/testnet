// create_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(mid: UInt64, percentage: UFix64)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let requestGen   : &DAAM.RequestGenerator
  let metadataGen  : &DAAM.MetadataGenerator

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
      self.metadataGen  = auctioneer.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
  }

  execute {
      let metadata <- self.metadataGen.generateMetadata(mid: mid)
      let request <- self.requestGen.getRequest(metadata: &metadata as &DAAM.MetadataHolder)

      self.auctionHouse.createAuction(metadata: <-metadata, request: <-request, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)!

      log("New Auction has been created.")
  }
}
