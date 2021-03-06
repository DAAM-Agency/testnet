// submit_accept.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import FungibleToken from 0x9a0766d93b6608b7 
import Categories    from 0xa4ad5ea5c0bd2fba
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V21          from 0xa4ad5ea5c0bd2fba

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "http": return MetadataViews.HTTPFile(url: string_cid)
        default: return DAAM_V21.OnChain(file: string_cid)
    }
}

transaction(name: String, max: UInt64?, featured: Bool, categories: [String], inCollection: {String:[UInt64]}?, description: String, misc: String, // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?, percentage: UFix64)                                                      // Royalty percentage for Creator(s)
{    
    //let creator     : AuthAccount
    let requestGen  : &DAAM_V21.RequestGenerator
    let metadataGen : &DAAM_V21.MetadataGenerator

    let name        : String
    let max         : UInt64?
    let featured    : Bool
    var categories  : [Categories.Category]
    let inCollection: {String:[UInt64]}?
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}
    let royalties   : MetadataViews.Royalties

    prepare(creator: AuthAccount) {
        self.metadataGen = creator.borrow<&DAAM_V21.MetadataGenerator>(from: DAAM_V21.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM_V21.RequestGenerator>( from: DAAM_V21.requestStoragePath)!

        self.name         = name
        self.max          = max
        self.featured     = featured
        self.description  = description
        self.inCollection = inCollection
        self.interact     = interact
        self.misc         = misc
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: thumbnailType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, type_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}
        let royalties    = [ MetadataViews.Royalty(
            recipient: creator.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),
            cut: percentage,
            description: "Creator Royalty" )
        ]
        self.royalties = MetadataViews.Royalties(royalties)
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
    }

    pre { percentage >= 0.01 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, featured: self.featured, categories: self.categories, inCollection: self.inCollection,
        description: self.description, misc: self.misc, thumbnail: self.thumbnail, file: self.file, interact: self.interact, )

        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, royalties: self.royalties)

        log("Metadata Submitted: ".concat(mid.toString()))
    }
}
