// submit_nft.cdc
// Creator uses to submit Metadata

import Categories from 0xfd43f9148d4b725d
import DAAM       from 0xfd43f9148d4b725d
transaction(series: UInt64, categories: [String], data: String,  thumbnail: String, file: String)
{    
    let metadataGen : &DAAM.MetadataGenerator
    let series      : UInt64   // series total, number of prints. 0 = Unlimited [counter, total]
    let category    : [Categories.Category]
    let collection  : CollectionData?
    let name        : String
    let description : String   // JSON see metadata.json all data ABOUT the NFT is stored here
    let thumbnail   : {MetadataViews.File}   // JSON see metadata.json all thumbnails are stored here
    let file        : MetadataViews.Media 

    prepare(creator: AuthAccount) {
        //self.creator = creator
        self.metadataGen = creator.borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)!

        self.series      = series!                // total prints
        self.counter     = 1                      // current print of total prints
        self.name        = name!
        self.description = description!           // data,about,misc page
        self.thumbnail   = thumbnail!             // thumbnail are stored here
        self.file        = file!        
        self.category = []
        for cat in categories {
            self.categories.append(Categories.Category(cat))
        }
    }

    execute {
        self.metadataGen.addMetadata(series: self.series, categories: self.categories, data: self.data, thumbnail: self.thumbnail, file: self.file)       
        log("Metadata Submitted")
    }
}
