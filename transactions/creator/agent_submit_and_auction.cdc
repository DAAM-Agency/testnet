// agent_submit_and_auction.cdc
// Agent uses to submit Metadata for their Creator and then creates an Auction on their behalf
// Note: Still requires Creator to accept Auction see: manage_deposot.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import FUSD             from 0x0bb80b2a4cb38cdf
import MetadataViews    from 0x631e88ae7f1d7c20
import Categories       from 0xa4ad5ea5c0bd2fba
import DAAM_Mainnet             from 0xa4ad5ea5c0bd2fba
import AuctionHouse_Mainnet     from 0x045a1763c93006ca

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "http": return MetadataViews.HTTPFile(url: string_cid)
        default: return DAAM_Mainnet.OnChain(file: string_cid)
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
    let agent       : &DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}

    // Auction
    let auctionHouse    : &AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}
    let metadataCap     : Capability<&DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorMint}>
    let metadataGen     : &DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorMint, DAAM_Mainnet.MetadataGeneratorPublic}
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
            .getCapability<&DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorMint, DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath).borrow()!

        self.metadataCap  = getAccount(creator)
            .getCapability<&DAAM_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorMint}>
            (DAAM_Mainnet.metadataPublicPath)

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
        self.agent = agent.borrow<&DAAM_Mainnet.Admin{DAAM_Mainnet.Agent}>(from: DAAM_Mainnet.adminStoragePath)!

        self.auctionHouse = getAccount(creator)
            .getCapability<&AuctionHouse_Mainnet.AuctionWallet{AuctionHouse_Mainnet.AuctionWalletPublic}>
            (AuctionHouse_Mainnet.auctionPublicPath)
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
