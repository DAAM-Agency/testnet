// create_auction.cdc
// Used to create an auction for an NFT

import AuctionHouse_V15     from 0x045a1763c93006ca
import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V22.V22             from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V22             from 0xa4ad5ea5c0bd2fba
>>>>>>> 586a0096 (updated FUSD Address)
import FUSD             from 0xe223d8a629e49c68

transaction(isMetadata: Bool, id: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
  /*requiredCurrency: Type,*/ incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
  reserve: UFix64, buyNow: UFix64, reprint: UInt64?)
{

  let auctionHouse : &AuctionHouse_V15.AuctionWallet
  let nftCollection: &DAAM_V22.Collection
  let metadataCap  : Capability<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorMint}>?

  let id          : UInt64
  let start       : UFix64
  let length      : UFix64
  let isExtended  : Bool
  let extendedTime: UFix64
  let incrementByPrice: Bool
  let incrementAmount : UFix64
  let startingBid : UFix64?
  let reserve     : UFix64
  let buyNow      : UFix64
  let isMetadata  : Bool
  let reprint     : UInt64?

  prepare(auctioneer: AuthAccount) {
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse_V15.AuctionWallet>(from: AuctionHouse_V15.auctionStoragePath)!
<<<<<<< HEAD
    self.nftCollection = auctioneer.borrow<&DAAM_V22.Collection>(from: DAAM_V22.V22.collectionStoragePath)!
=======
    self.nftCollection = auctioneer.borrow<&DAAM_V22.Collection>(from: DAAM_V22.collectionStoragePath)!
>>>>>>> 586a0096 (updated FUSD Address)
    self.metadataCap  = (isMetadata) ? auctioneer.getCapability<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorMint}>(DAAM_V22.metadataPublicPath) : nil

    self.id               = id
    self.start            = start
    self.length           = length
    self.isExtended       = isExtended
    self.extendedTime     = extendedTime
    self.incrementByPrice = incrementByPrice
    self.incrementAmount  = incrementAmount
    self.startingBid      = startingBid
    self.reserve          = reserve
    self.buyNow           = buyNow
    self.isMetadata       = isMetadata
    self.reprint          = reprint
  }

  execute {
      let vault <- FUSD.createEmptyVault()
      log(vault.getType())

      var nft: @DAAM_V22.NFT? <- nil
      if !self.isMetadata {
        let old <- nft <- self.nftCollection.withdraw(withdrawID: self.id) as! @DAAM_V22.NFT
        destroy old
      }

      let aid = self.auctionHouse.createAuction(metadataGenerator: self.metadataCap, nft: <-nft, id: self.id,
        start: self.start, length: self.length, isExtended: self.isExtended, extendedTime: self.extendedTime,
        vault: <-vault, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprint)

      log("New Auction has been created. AID: ".concat(aid.toString() ))
  }
}
