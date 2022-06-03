// submit_accept.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import Categories    from 0xfd43f9148d4b725d
import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, file_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && file_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: file_path) }
    switch file_path! {
        case "file": return DAAM.OnChain(file: string_cid)
        case "http": return MetadataViews.HTTPFile(url: string_cid)
    }
    panic("Thumbnail Type is invalid")
}

transaction(name: String, max: UInt64?, categories: [String], inCollection: [UInt64]?, description: String, // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    percentage: UFix64)                                                      // Royalty percentage for Creator(s)
{    
    //let creator     : AuthAccount
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let inCollection: [UInt64]?
    let description : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}
    let percentage  : UFix64

    prepare(creator: AuthAccount) {
        //self.creator     = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!

        self.name         = name
        self.max          = max
        self.description  = description
        self.inCollection = inCollection
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, file_path: fileType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, file_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
        self.percentage = percentage
    }

    pre { percentage >= 0.1 || percentage <= 0.3 : "Percentage must be between 10% to 30%." }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, categories: self.categories, inCollection: self.inCollection,
        description: self.description, thumbnail: self.thumbnail, file: self.file)

        self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, percentage: self.percentage)

        log("Metadata Submitted: ".concat(mid.toString()))
    }
}
