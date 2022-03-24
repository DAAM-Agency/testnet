// submit_all.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import DAAM_V7      from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x01837e15023c9249

transaction(
    // Metadata Arguments
    series: UInt64, data: String,  thumbnail: String, file: String,
    // Request Arguments
    percentage: UFix64, 
    // Auction Arguments
    start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, incrementByPrice: Bool,
    incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: Bool
)

{    
    let creator     : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator
    let metadataCap : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>
    let auctionHouse: &AuctionHouse.AuctionWallet

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
        self.creator      = creator
        self.metadataGen  = self.creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen   = self.creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!
        self.auctionHouse = self.creator.borrow<&AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)!
        
        self.metadataCap  = self.creator.getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>(DAAM.metadataPrivatePath)!

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

    pre { percentage >= 0.1 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(creator: self.creator, series: self.series, categories: self.categories, data: self.data, thumbnail: self.thumbnail, file: self.file)       
        let metadata = self.metadataGen.getMetadataRef(mid: mid)
        
        self.requestGen.acceptDefault(creator: self.creator, metadata: metadata, percentage: percentage)

        self.auctionHouse.createOriginalAuction(
            metadataGenerator: self.metadataCap, mid: mid, start: self.start, length: self.length, isExtended: self.isExtended,
            extendedTime: self.extendedTime, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
            startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprintSeries
        )!

        log("New Auction has been created.")
        log("Metadata Submitted: ".concat(mid.toString()).concat(" with a Royalty Percentage: ".concat((self.percentage*100.0).toString()).concat(" Accepted.")))
    }
}

