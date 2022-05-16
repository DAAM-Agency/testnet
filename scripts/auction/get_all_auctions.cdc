// get_all_auctions.cdc
// Return all auctions

import DAAM         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

pub struct Data {
        pub(set) var auctionID   : UInt64       // Auction ID number. Note: Series auctions keep the same number. 
        pub(set) var mid         : UInt64       // collect Metadata ID
        pub(set) var start       : UFix64       // timestamp
        pub(set) var length        : UFix64   // post{!isExtended && length == before(length)}
        pub(set) var isExtended    : Bool     // true = Auction extends with every bid.
        pub(set) var extendedTime  : UFix64   // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub(set) var leader        : Address? // leading bidder
        pub(set) var minBid        : UFix64?  // minimum bid
        pub(set) var startingBid   : UFix64?  // the starting bid od an auction. Nil = No Bidding. Direct Purchase
        pub(set) var reserve       : UFix64   // the reserve. must be sold at min price.
        pub(set) var buyNow        : UFix64   // buy now price
        pub(set) var reprintSeries : Bool     // Active Series Minter (if series)
        pub(set) var auctionLog    : {Address: UFix64}    // {Bidders, Amount} // Log of the Auction
        pub(set) var timeLeft      : UFix64?
        pub let metadata           : DAAM.MetadataHolder?

        init(metadata: DAAM.MetadataHolder?) {
            self.auctionID = 0
            self.mid = 0
            self.start = 0.0
            self.length = 0.0
            self.isExtended = false
            self.extendedTime = 0.0
            self.leader = nil
            self.minBid = nil
            self.startingBid = nil
            self.reserve = 0.0
            self.buyNow = 0.0
            self.reprintSeries = false
            self.auctionLog = {}
            self.timeLeft = nil
            self.metadata = metadata
        }
}

pub fun getData(auction: &AuctionHouse.Auction, metadata: DAAM.MetadataHolder?): Data {
    var data = Data(metadata: metadata)
    data.auctionID = auction.auctionID
    data.mid = auction.mid
    data.start = auction.start
    data.length = auction.length
    data.isExtended = auction.isExtended
    data.extendedTime = auction.extendedTime
    data.leader = auction.leader
    data.minBid = auction.minBid
    data.startingBid = auction.startingBid
    data.reserve = auction.reserve
    data.buyNow = auction.buyNow
    data.reprintSeries = auction.reprintSeries
    data.auctionLog = {}
    data.timeLeft = auction.timeLeft()
    return data
} 

pub fun main(): {Address : [Data] } {    
    let auctionList = AuctionHouse.getCurrentAuctions() // get Auctioneers and AIDs {Address : [aid]}
    var detailedList: {Address : [Data] } = {}     // create conversation type for react
    for auctionieer in auctionList.keys {
        var convertAuctionList: [Data] = []        // converted data
        for aid in auctionList[auctionieer]! {
            let auctionHouse = getAccount(auction)
                .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
                (AuctionHouse.auctionPublicPath)
                .borrow()!

            let metadata = auctionHouse.item(aid).itemInfo() 

            convertAuctionList.append(
                getData(auction: auctionHouse.item(aid), metadata: metadata)
            ) // Save converted data
        }
        detailedList.insert(key: auctionieer, convertAuctionList)  // Append auctionieer with Data
    }
    return detailedList
}