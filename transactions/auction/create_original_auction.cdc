// create_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM             from 0xfd43f9148d4b725d

transaction(mid: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let metadataCap  : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>
  let metadataGen  : &DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}

  prepare(auctioneer: AuthAccount) {
      self.auctionHouse = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
      self.metadataGen  = auctioneer.borrow<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>(from: DAAM.metadataStoragePath)!
      //let metadataCap2 = auctioneer.getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>(DAAM.metadataPublicPath)!
      self.metadataCap = self.metadataGen.grantAccess(creator: auctioneer)
      log (self.metadataGen != nil)
      log (self.auctionHouse != nil)
      log (self.metadataCap.borrow() != nil)
  }

  execute {
      self.auctionHouse.createOriginalAuction(metadataGenerator: self.metadataCap, mid: mid, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)!

      log("New Auction has been created.")
  }
}
