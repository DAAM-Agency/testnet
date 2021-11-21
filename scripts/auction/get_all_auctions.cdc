// get_all_auctions.cdc
// Return all auctions

import AuctionHouse  from 0x045a1763c93006ca

pub struct data {
        pub var auctionID   : UInt64       // Auction ID number. Note: Series auctions keep the same number. 
        pub var mid         : UInt64       // collect Metadata ID
        pub var start       : UFix64       // timestamp
        pub var length        : UFix64   // post{!isExtended && length == before(length)}
        pub var isExtended    : Bool     // true = Auction extends with every bid.
        pub var extendedTime  : UFix64   // when isExtended=true and extendedTime = 0.0. This is equal to a direct Purchase. // Time of Extension.
        pub var leader        : Address? // leading bidder
        pub var minBid        : UFix64?  // minimum bid
        pub var startingBid   : UFix64?  // the starting bid od an auction. Nil = No Bidding. Direct Purchase
        pub var reserve       : UFix64   // the reserve. must be sold at min price.
        pub var buyNow        : UFix64   // buy now price
        pub var reprintSeries : Bool     // Active Series Minter (if series)
        pub var auctionLog    : {Address: UFix64}    // {Bidders, Amount} // Log of the Auction

        init() {
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
        }
}

pub fun getData(_ auction: &AuctionHouse.Auction): data {
    
    return
} 

pub fun main(): {Address : [data] } {    
    let auctionList = AuctionHouse.currentAuctions
    var detailedList: {Address : [data] } = {}
    for auctionieer in auctionList.keys {
        var convertAuctionList: [data] = []
        for aid in auctionList[auctionieer] {
            let auctionHouse = getAccount(auctionieer)
            .getCapability<&{AuctionHouse.AuctionPublic}>(AuctionHouse.auctionPublicPath)
            .borrow()!

            convertAuctionList.append(auctionHouse.item(aid))            
        }
        detailedList.insert(key: auctionieer, convertAuctionList)
    }
    return detailedList
}