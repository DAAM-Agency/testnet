// agent_submit_and_auction.cdc
// Agent uses to submit Metadata for their Creator and then creates an Auction on their behalf
// Note: Still requires Creator to accept Auction see: manage_deposot.cdc

import NonFungibleToken from 0x1d7e57aa55817448
import FUSD             from 0x3c5959b568896393
import MetadataViews    from 0x1d7e57aa55817448
import Categories       from 0x7db4d10c78bad30a
import DAAM             from 0x7db4d10c78bad30a
import AuctionHouse     from 0x045a1763c93006ca

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "http": return MetadataViews.HTTPFile(url: string_cid)
        default: return DAAM.OnChain(file: string_cid)
    }
}
// Metadata Arguments
transaction(creator: Address, name: String, max: UInt64?, categories: [String], description: String, misc: String, 
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?,
    //Auction Setting
    start: UFix64, length: UFix64, isExtended: Bool, extendedTime: UFix64, /*vault: @FungibleToken.Vault,*/
    incrementByPrice: Bool, incrementAmount: UFix64, startingBid: UFix64?, reserve: UFix64, buyNow: UFix64, reprintSeries: UInt64?)
{   
    // Metadata
    let creator     : Address   
    let agent       : &DAAM.Admin{DAAM.Agent}

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}

    // Auction
    let auctionHouse    : &AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}
    let metadataCap     : Capability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>
    let metadataGen     : &DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}
    let start           : UFix64
    let length          : UFix64
    let isExtended      : Bool
    let extendedTime    : UFix64
    let incrementByPrice: Bool
    let incrementAmount : UFix64
    let startingBid     : UFix64?
    let reserve         : UFix64
    let buyNow          : UFix64
    let reprintSeries   : UInt64?

    prepare(agent: AuthAccount) {
        // Metadata
        self.creator      = creator
        self.metadataGen  = getAccount(self.creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath).borrow()!

        self.metadataCap  = getAccount(creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint}>
            (DAAM.metadataPublicPath)

        self.name         = name
        self.max          = max
        self.description  = description
        self.interact     = interact
        self.misc         = misc
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: fileType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, type_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }

        // Auction
        self.agent = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!

        self.auctionHouse = getAccount(creator)
            .getCapability<&AuctionHouse.AuctionWallet{AuctionHouse.AuctionWalletPublic}>
            (AuctionHouse.auctionPublicPath)
            .borrow()!
        
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
    }

    execute {
        // Metadata
        let metadata <- self.agent.createMetadata(creator: self.creator, name: self.name, max: self.max, categories: self.categories, description: self.description, misc: self.misc,
            thumbnail: self.thumbnail, file: self.file, interact: self.interact)
        let mid = metadata.mid
        self.metadataGen.returnMetadata(metadata: <- metadata)
        log("Metadata Submitted: ".concat(mid.toString()))

        // Auction
        let vault <- FUSD.createEmptyVault()

        let aid = self.auctionHouse.deposit(agent: self.agent, metadataGenerator: self.metadataCap, mid: mid, start: self.start, length: self.length,
        isExtended: self.isExtended, extendedTime: self.extendedTime, vault:<-vault, incrementByPrice: self.incrementByPrice, incrementAmount: self.incrementAmount,
        startingBid: self.startingBid, reserve: self.reserve, buyNow: self.buyNow, reprintSeries: self.reprintSeries)
        
        log("Deposited AID: ".concat(aid.toString()))
    }
}
