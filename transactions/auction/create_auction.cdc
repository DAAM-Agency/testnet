
// create_auction.cdc

import AuctionHouse     from 0x045a1763c93006ca
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

transaction(tokenID: UInt64, start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64,
    isIncrementPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64)
{
    prepare(signer: AuthAccount) {
        let increment = {isIncrementPrice: incrementAmount}
        let auctionHouse = signer.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
        let collection = signer.borrow<&NonFungibleToken.Collection>(from: DAAM.collectionStoragePath)!
        let token <- collection.withdraw(withdrawID: tokenID)!

        auctionHouse.createAuction(token: <-token, start: start, length: length, isExtended: isExtended, extendedTime: extendedTime,
            increment: increment, startingBid: startingBid, reserve: reserve, buyNow: buyNow)

        log("New Auction created.")
    }
}
