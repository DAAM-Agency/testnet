// submit_and_auction.cdc
// Creator uses to submit Metadata & Approve Rpyalty
// Used to create an auction for a first-time sale.

import Categories   from 0xa4ad5ea5c0bd2fba
import DAAM_V10         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V2 from 0x1837e15023c9249

transaction(
    // Metadata Arguments
    series: UInt64, categories: [String], data: String,  thumbnail: String, file: String,
    // Request Arguments
    percentage: UFix64, 
    // Auction Arguments
    start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
    incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool
)

{    
    let requestGen  : &DAAM_V10.RequestGenerator
    let metadataGen : &DAAM_V10.MetadataGenerator
    let metadataCap : Capability<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorMint}>
    let auctionHouse: &AuctionHouse_V2.AuctionWallet

    let series      : UInt64
    let data        : String
    var categories  : [Categories.Category]
    let thumbnail   : String
    let file        : String

    let percentage  : UFix64

    let start       : UFix64
    let length      : UFix64
    let isExtended  : Bool
    let extendedTime: UFix64
    let incrementByPrice: Bool
    let incrementAmount : UFix64
    let startingBid : UFix64?
    let reserve     : UFix64
    let buyNow      : UFix64
    let reprintSeries   : Bool

    prepare(creator: AuthAccount) {
        self.metadataGen  = creator.borrow<&DAAM_V10.MetadataGenerator>(from: DAAM_V10.metadataStoragePath)!
        self.requestGen   = creator.borrow<&DAAM_V10.RequestGenerator>( from: DAAM_V10.requestStoragePath)!
        self.auctionHouse = creator.borrow<&AuctionHouse_V2.AuctionWallet>(from: AuctionHouse_V2.auctionStoragePath)!
        self.metadataCap  = creator.getCapability<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorMint}>(DAAM_V10.metadataPublicPath)!

        self.series     = series
        self.data       = data
        self.thumbnail  = thumbnail
        self.file       = file
        self.percentage = percentage

        self.start            = start
        self.length           = length
        self.isExtended       = isExtended
        self.extendedTime     = extendedTime
        self.incrementByPrice = incrementByPrice
        self.incrementAmount  = incrementAmount
        self.startingBid      = startingBid
        self.reserve          = reserve
        self.buyNow           = buyNow
        self.reprintSeries    = reprintSeries

        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
    }

    pre { percentage >= 0.01 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(series: self.series, categories: self.categories, data: self.data, thumbnail: self.thumbnail, file: self.file)       
        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, percentage: self.percentage)

        self.auctionHouse.createOriginalAuction(
            metadataGenerator: self.metadataCap, mid: mid, start: self.start, length: self.length, isExtended: self.isExtended,
            extendedTime: self.extendedTime, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
            startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprintSeries
        )!

        log("New Auction has been created.")
        log("Metadata Submitted: ".concat(mid.toString()).concat(" with a Royalty Percentage: ".concat((self.percentage*100.0).toString()).concat(" Accepted.")))
    }
}
