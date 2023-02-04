// agent_submit.cdc
// Agent uses to submit Metadata for their Creator

import Categories    from 0x7db4d10c78bad30a
import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

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

transaction(creator: Address, name: String, max: UInt64?, categories: [String], description: String, misc: String, // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?)
{    
    let creator     : Address   
    let metadataGen : &DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}
    let agent       : &DAAM.Admin{DAAM.Agent}

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}

    prepare(agent: AuthAccount) {
        self.creator      = creator
        self.metadataGen  = getAccount(self.creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorMint, DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath).borrow()!
        self.agent        = agent.borrow<&DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)!
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
    }

    execute {
        let metadata <- self.agent.createMetadata(creator: self.creator, name: self.name, max: self.max, categories: self.categories, description: self.description, misc: self.misc,
            thumbnail: self.thumbnail, file: self.file, interact: self.interact)
        let mid = metadata.mid
        self.metadataGen.returnMetadata(metadata: <- metadata)
        log("Metadata Submitted: ".concat(mid.toString()))
    }
}
