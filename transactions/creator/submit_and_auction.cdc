// submit_and_auction.cdc
// Creator uses to submit Metadata & Approve Rpyalty
// Used to create an auction for a first-time sale.

import FungibleToken from 0x9a0766d93b6608b7 
import Categories    from 0xa4ad5ea5c0bd2fba
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V23          from 0xa4ad5ea5c0bd2fba
<<<<<<< HEAD
import AuctionHouse_V16  from 0x01837e15023c9249
import FUSD          from 0xe223d8a629e49c68
=======
import AuctionHouse_V16  from 0x01837e15023c9249
import FUSD          from 0x0xe223d8a629e49c68
>>>>>>> tomerge

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "text": return DAAM_V23.OnChain(file: string_cid)
        case "jpg": return DAAM_V23.OnChain(file: string_cid)
        case "jpg": return DAAM_V23.OnChain(file: string_cid)
        case "png": return DAAM_V23.OnChain(file: string_cid)
        case "bmp": return DAAM_V23.OnChain(file: string_cid)
        case "gif": return DAAM_V23.OnChain(file: string_cid)
        case "http": return MetadataViews.HTTPFile(url: string_cid)
    }
    panic("Type is invalid")
}

transaction(
    name: String, max: UInt64?, categories: [String], description: String, misc: String,  // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?, percentage: UFix64,
    
    start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, /*requiredCurrency: Type,*/
    incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64, reserve: UFix64, buyNow: UFix64, reprint: UInt64?
    )
{    
<<<<<<< HEAD
    let requestGen  : &DAAM_V23.RequestGenerator
    let metadataGen : &DAAM_V23.MetadataGenerator
    let metadataCap : Capability<&DAAM_V23.MetadataGenerator{DAAM_V23.MetadataGeneratorMint}>
=======
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator
    let metadataCap : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>
>>>>>>> tomerge
    let auctionHouse: &AuctionHouse_V16.AuctionWallet

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}
    let royalties   : MetadataViews.Royalties

    // Auction
    let start       : UFix64
    let length      : UFix64
    let isExtended  : Bool
    let extendedTime: UFix64
    let incrementByPrice: Bool
    let incrementAmount : UFix64
    let startingBid : UFix64?
    let reserve     : UFix64
    let buyNow      : UFix64
    let reprint     : UInt64?

    prepare(creator: AuthAccount) {
<<<<<<< HEAD
        self.metadataGen  = creator.borrow<&DAAM_V23.MetadataGenerator>(from: DAAM_V23.metadataStoragePath)!
        self.requestGen   = creator.borrow<&DAAM_V23.RequestGenerator>( from: DAAM_V23.requestStoragePath)!
        self.auctionHouse = creator.borrow<&AuctionHouse_V16.AuctionWallet>(from: AuctionHouse_V16.auctionStoragePath)!
        self.metadataCap  = creator.getCapability<&DAAM_V23.MetadataGenerator{DAAM_V23.MetadataGeneratorMint}>(DAAM_V23.metadataPublicPath)!
=======
        self.metadataGen  = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM_V23.metadataStoragePath)!
        self.requestGen   = creator.borrow<&DAAM.RequestGenerator>( from: DAAM_V23.requestStoragePath)!
        self.auctionHouse = creator.borrow<&AuctionHouse_V16.AuctionWallet>(from: AuctionHouse_V16.auctionStoragePath)!
        self.metadataCap  = creator.getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>(DAAM.metadataPublicPath)!
>>>>>>> tomerge
        
        self.name         = name
        self.max          = max
        self.description  = description
        self.interact     = interact
        self.misc         = misc
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: fileType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, type_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}

        let royalties    = [ MetadataViews.Royalty(
            receiver: creator.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalties = MetadataViews.Royalties(royalties)

        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }

        self.start            = start
        self.length           = length
        self.isExtended       = isExtended
        self.extendedTime     = extendedTime
        self.incrementByPrice = incrementByPrice
        self.incrementAmount  = incrementAmount
        self.startingBid      = startingBid
        self.reserve          = reserve
        self.buyNow           = buyNow
        self.reprint          = reprint 
    }

    pre { percentage >= 0.01 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, categories: self.categories,
        description: self.description, misc: self.misc, thumbnail: self.thumbnail, file: self.file, interact: self.interact, )

        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, royalties: self.royalties)
        let vault <- FUSD.createEmptyVault()

        self.auctionHouse.createAuction(
            metadataGenerator: self.metadataCap, nft: nil, id: mid, start: self.start, length: self.length, isExtended: self.isExtended,
            extendedTime: self.extendedTime, vault: <-vault ,incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
            startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprint
        )!

        log("New Auction has been created.")
        log("Metadata Submitted: ".concat(mid.toString()))
    }
}

