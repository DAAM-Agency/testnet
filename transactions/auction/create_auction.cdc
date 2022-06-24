// create_auction.cdc
// Used to create an auction for an NFT

<<<<<<< HEAD
import AuctionHouse_V4     from 0x1837e15023c9249
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V14         from 0xa4ad5ea5c0bd2fba
=======
import AuctionHouse_V5     from 0x045a1763c93006ca
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V15             from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15
import FUSD             from 0xe223d8a629e49c68

transaction(isMetadata: Bool, id: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
  /*requiredCurrency: Type,*/ incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64,
  reserve: UFix64, buyNow: UFix64, reprint: UInt64?)
{

<<<<<<< HEAD
  let auctionHouse : &AuctionHouse_V4.AuctionWallet
  let nftCollection: &DAAM_V14.Collection
  let metadataCap  : Capability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorMint}>?
=======
  let auctionHouse : &AuctionHouse_V5.AuctionWallet
  let nftCollection: &DAAM_V15.Collection
  let metadataCap  : Capability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorMint}>?
>>>>>>> DAAM_V15

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
<<<<<<< HEAD
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse_V4.AuctionWallet>(from: AuctionHouse_V4.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&DAAM_V14.Collection>(from: DAAM_V14.collectionStoragePath)!
    self.metadataCap  = (isMetadata) ? auctioneer.getCapability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorMint}>(DAAM_V14.metadataPublicPath) : nil
=======
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse_V5.AuctionWallet>(from: AuctionHouse_V5.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&DAAM_V15.Collection>(from: DAAM_V15.collectionStoragePath)!
    self.metadataCap  = (isMetadata) ? auctioneer.getCapability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorMint}>(DAAM_V15.metadataPublicPath) : nil
>>>>>>> DAAM_V15

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

<<<<<<< HEAD
      var nft: @DAAM_V14.NFT? <- nil
      if !self.isMetadata {
        let old <- nft <- self.nftCollection.withdraw(withdrawID: self.id) as! @DAAM_V14.NFT
=======
      var nft: @DAAM_V15.NFT? <- nil
      if !self.isMetadata {
        let old <- nft <- self.nftCollection.withdraw(withdrawID: self.id) as! @DAAM_V15.NFT
>>>>>>> DAAM_V15
        destroy old
      }

      let aid = self.auctionHouse.createAuction(metadataGenerator: self.metadataCap, nft: <-nft, id: self.id,
        start: self.start, length: self.length, isExtended: self.isExtended, extendedTime: self.extendedTime,
        vault: <-vault, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprint)

      log("New Auction has been created. AID: ".concat(aid.toString() ))
  }
}
