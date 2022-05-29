// submit_nft.cdc
// Creator uses to submit Metadata

import Categories    from 0xfd43f9148d4b725d
import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d
transaction(series: UInt64, categories: [String], name: String, description: String,
    collectionName: String, thumbnail: String, file: String)
{    
    let metadataGen : &DAAM.MetadataGenerator
    let series      : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
    let category    : [Categories.Category]
    let collection  : DAAM.CollectionData?
    let name        : String
    let description : String   // JSON see metadata.json all data ABOUT the NFT is stored here
    let thumbnail   : {MetadataViews.File}   // JSON see metadata.json all thumbnails are stored here
    let file        : MetadataViews.Media 

    prepare(creator: AuthAccount) {
        //self.creator = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!
        self.series      = series             // total prints
        self.name        = name
        self.collection  = DAAM.CollectiionData(name: collectionName)
        self.description = description          // data,about,misc page
        self.thumbnail   = thumbnail           // thumbnail are stored here
        self.file        = file  

        self.category = []
        for cat in categories {
            self.category.append(Categories.Category(cat))
        }
    }

    execute {
        self.metadataGen.addMetadata(series: self.series, categories: self.category, name: self.name, description: self.description,
            collection: self.collection, thumbnail: self.thumbnail, file: self,file)       
        log("Metadata Submitted")
    }
}
