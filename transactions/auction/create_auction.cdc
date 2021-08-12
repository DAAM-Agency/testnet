// create_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(tokenID: Uint64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
  incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool)
{
  let auctionHouse : &AuctionHouse.AuctionWallet
  let nftCollection: &DAAM.Collection

  prepare(auctioneer: AuthAccount) {
    self.auctionHouse  = auctioneer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
    self.nftCollection = auctioneer.borrow<&NonFungibleToken.Collection>(from: DAAM.collectionStoragePath)!
  }

  execute {
      let nft <- self.nftCollection.withdraw(withdrawID: tokenID) as! @DAAM.NFT

      self.auctionHouse.createAuction(nft: <-nft, start: start, length: length, isExtended: isExtended,
        extendedTime: extendedTime, incrementByPrice: incrementByPrice, incrementAmount: incrementAmount,
        startingBid: startingBid, reserve: reserve, buyNow: buyNow, reprintSeries: reprintSeries)

      log("New Auction created.")
  }
}
