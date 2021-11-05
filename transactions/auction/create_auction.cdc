// create_auction.cdc

import AuctionHouse_V1     from 0x045a1763c93006ca
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V3             from 0xa4ad5ea5c0bd2fba

transaction(tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
{
  let auctionHouse : &AuctionHouse_V1.AuctionWallet
  let nftCollection: &DAAM_V3.Collection

  prepare(auctioneer: AuthAccount) {
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse_V1.AuctionWallet>(from: AuctionHouse_V1.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&DAAM.Collection>(from: DAAM_V3.collectionStoragePath)!
  }

  execute {
      let nft <- self.nftCollection.withdraw(withdrawID: tokenID) as! @DAAM_V3.NFT

      self.auctionHouse.createAuction(nft: <-nft, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow)

      log("New Auction created.")
  }
}
