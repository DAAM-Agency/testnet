// submit_nft.cdc
// Creator uses to submit Metadata

import Categories    from 0xa4ad5ea5c0bd2fba
import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V23          from 0xa4ad5ea5c0bd2fba

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "http": return MetadataViews.HTTPFile(url: string_cid)
        default: return DAAM_V23.OnChain(file: string_cid)
    }
}

transaction(name: String, max: UInt64?, categories: [String], description: String, // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?)
{    
    //let creator     : AuthAccount
    let requestGen  : &DAAM_V23.RequestGenerator
    let metadataGen : &DAAM_V23.MetadataGenerator

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}

    prepare(creator: AuthAccount) {
        //self.creator     = creator
        self.metadataGen = creator.borrow<&DAAM_V23.MetadataGenerator>(from: DAAM_V23.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM_V23.RequestGenerator>( from: DAAM_V23.requestStoragePath)!

        self.name         = name
        self.max          = max
        self.description  = description
        self.interact     = interact
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: fileType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, type_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
    }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, categories: self.categories,
            description: self.description, thumbnail: self.thumbnail, file: self.file, interact: self.interact)

        log("Metadata Submitted: ".concat(mid.toString()))
    }
}
