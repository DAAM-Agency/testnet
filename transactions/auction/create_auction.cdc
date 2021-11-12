// create_auction.cdc
// Used to create an auction for an NFT

import AuctionHouse     from 0x01837e15023c9249
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V5             from 0xa4ad5ea5c0bd2fba

transaction(auctionID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let nftCollection: &DAAM_V5.Collection

  prepare(auctioneer: AuthAccount) {
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&DAAM_V5.Collection>(from: DAAM_V5.collectionStoragePath)!
  }

  execute {
      let nft <- self.nftCollection.withdraw(withdrawID: auctionID) as! @DAAM_V5.NFT

      self.auctionHouse.createAuction(nft: <-nft, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow)

      log("New Auction created.")
  }
}
