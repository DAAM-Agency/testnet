// submit_accept.cdc
// Creator uses to submit Metadata & Approve Rpyalty

import FungibleToken from 0xf233dcee88fe0abe 
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

transaction(name: String, max: UInt64?, categories: [String], description: String, misc: String, // Metadata information
    ipfs_thumbnail: Bool, thumbnail_cid: String, thumbnailType_path: String, // Thumbnail setting: IPFS, HTTP(S), FILE(OnChain)
    ipfs_file: Bool, file_cid: String, fileType_path: String,                // File setting: IPFS, HTTP(S), FILE(OnChain)
    interact: AnyStruct?,  percentage: UFix64?)                               // Royalty percentage for Creator(s), when nil only submitting and entering bargin mode unless
                                                                                // within default range, then accept default can be used.
{    
    let creatorCap  : Capability<&AnyResource{FungibleToken.Receiver}>
    let requestGen  : &DAAM.RequestGenerator
    let metadataGen : &DAAM.MetadataGenerator

    let name        : String
    let max         : UInt64?
    var categories  : [Categories.Category]
    let interact    : AnyStruct?
    let description : String
    let misc        : String
    let thumbnail   : {String : {MetadataViews.File}}
    let file        : {String : MetadataViews.Media}
    let percentage  : UFix64?

    prepare(creator: AuthAccount) {
        self.creatorCap  = creator.getCapability<&AnyResource{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath())
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.requestGen  = creator.borrow<&DAAM.RequestGenerator>( from: DAAM.requestStoragePath)!

        self.name         = name
        self.max          = max
        self.description  = description
        self.interact     = nil //interact
        self.misc         = misc
        self.thumbnail    = {thumbnailType_path : setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: thumbnailType_path)}
        let fileData      = setFile(ipfs: ipfs_file, string_cid: file_cid, type_path: fileType_path)
        let fileType      = ipfs_file ? "ipfs" : fileType_path
        self.file         = {fileType : MetadataViews.Media(file: fileData, mediaType: fileType)}
        
        self.categories = []
        for cat in categories {
            self.categories.append(Categories.Category(name: cat))
        }
        self.percentage = percentage
    }

    execute {
        let mid = self.metadataGen.addMetadata(name: self.name, max: self.max, categories: self.categories,
        description: self.description, misc: self.misc, thumbnail: self.thumbnail, file: self.file, interact: self.interact)
        
        log("Metadata Submitted: ".concat(mid.toString()))

        if self.percentage != nil {
            let royalties_init: [MetadataViews.Royalty] = [ MetadataViews.Royalty(
                receiver: self.creatorCap,
                cut: percentage!,
                description: "Creator Royalty"
            )]
            let royalties = MetadataViews.Royalties(royalties_init) 
            log(royalties)
            if self.percentage! >= 0.01 && self.percentage! <= 0.3 {
                self.requestGen.acceptDefault(mid: mid, metadataGen: self.metadataGen, royalties: royalties)
                log("Deal Accepted: ".concat(mid.toString()))
            } else {
                self.requestGen.createRequest(mid: mid, royalty: royalties)
                log("Bargining Started: ".concat(mid.toString()))
            }
        }
    }
    
}
